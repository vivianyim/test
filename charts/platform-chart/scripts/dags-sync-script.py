# This script is used to populate the EFS drive from which Airflow mounts dags
# in the development environment.
#
# The default location that Airflow uses is /opt/airflow/dags.
#
# The script is executed by the "dags-sync-cronjob" which is scheduled to trigger
# once per minute in the Kubernetes cluster in the development env.
#
# The script checks to see if the dag files from the latest git commit on Hyak "main"
# branch are present on the EFS drive. If they are not, then it copies the files
# to  the drive. It also tags to all dag objects with the branch name and
# current commit sha. These dag tags appear in the Airflow UI and can be used for filtering.
#
# The script then checks the S3 bucket for new deployment requests. These deployment
# requests are created by a GitHub action workflow called "Dag Sync Dev Env". Each
# deployment request provides action (create or delete), branch name, dag folder, and
# optional additional dag tags. A deployment request looks like this:
# {"action": "create", "branch": "dp-422", "dag_folder": "ga4", "dag_tags": "dp-422,dps"}
# {"action": "delete", "branch": "dp-422", "dag_folder": "ga4", "dag_tags": ""}
#
# This results in deploying the dag from the specified branch to Airflow in the development
# environment. The specified dag code is copied to the EFS drive in a new folder
# named after the branch name. Also, the branch name is added as a suffix to the dag id.
# Additionally, the dag is tagged with all provided tags as well as the branch name
# and the commit sha.
#
# All of the deployment requests are then moved to a "processed-requests" prefix on S3.


import os
import boto3
import json
import subprocess
from typing import Optional
from filecmp import dircmp

s3_client = boto3.client('s3')

aws_account = os.environ["AWS_ACCOUNT"].strip()
bucket_name = f"dps-hyak-deployment-artifacts-{aws_account}"

environment = os.environ["DEPLOYMENT_ENV"].strip()


def main():

    # create the dags directory if it is missing
    os.system('if [ ! -d "/opt/airflow/dags" ] ; then mkdir /opt/airflow/dags; fi')

    if environment in ["dev"]:
        # in dev env, sync the latest main branch by default
        sync_dags_main_branch()

    # process any existing deployment actions
    print("Processing deployment requests.")

    # get all deployment request objects from the s3 bucket
    s3_prefix = os.environ["S3_PREFIX"].strip()
    objects_dict = s3_client.list_objects(Bucket=bucket_name, Prefix=s3_prefix)

    # check if there are deployment requests
    if 'Contents' not in objects_dict:
        print("No new deployment requests. Nothing to do.")
    else:
        print("Found new deployment requests. Processing ...")

        # get all new deployment requests and iterate through them
        contents_list = objects_dict['Contents']
        for item in contents_list:
            deploy_item_dict = load_deployment_request(item)

            deploy_action = deploy_item_dict['action'].strip()
            deploy_branch = deploy_item_dict['branch'].strip()
            deploy_dag_folder = deploy_item_dict['dag_folder'].strip()
            deploy_dag_tags = deploy_item_dict['dag_tags'].strip()
            deploy_branch_tag = deploy_item_dict['branch_tag'].strip()

            if environment in ["stage", "prod"]:
                # For stage or prod envs, process deployment requests for tags on main branch only
                print(f"Checking out tag: {deploy_branch_tag}")
                os.system(f"git fetch --all --tags; git checkout tags/{deploy_branch_tag}")

                update_dags(branch_name="main", branch_sha=deploy_branch_tag)
            else:
                if deploy_action == "create":
                    print(f"Checking out branch {deploy_branch}")
                    os.system(f"git checkout .; git checkout {deploy_branch}; git pull --no-rebase")

                    current_sha = get_current_sha(deploy_branch)

                    update_dags(deploy_branch, current_sha, deploy_dag_folder, deploy_dag_tags)
                else:
                    # this is a 'delete' action
                    delete_dags(deploy_branch, deploy_dag_folder)

            # archive the deployment request
            archive_deployment_request(item, s3_prefix)

            print("Deployment complete.")


def sync_dags_main_branch():
    # checkout main branch and discard any changes if present
    os.system("git checkout main; git checkout .;")

    # get the current sha of main branch
    current_sha = get_current_sha("main")

    # check if the main branch needs to be synced
    result = subprocess.run(['grep', '-q', current_sha, '/opt/airflow/dags/hello_world/dag.py'])
    if result.returncode == 0:
        print(f"Main branch - git sha {current_sha} already exists. Doing nothing.")
    else:
        update_dags(branch_name="main", branch_sha=current_sha)
        print(f"Main branch updated to sha {current_sha}.")


def get_current_sha(branch_name):
    # get the current sha of the provided git branch
    current_sha = subprocess.run(['git', 'rev-parse', '--short', branch_name], stdout=subprocess.PIPE).stdout.decode('utf-8').strip()
    print(f"Branch: {branch_name}; current sha: {current_sha}")
    return current_sha


def update_dags(
    branch_name: str,
    branch_sha: str,
    dag_folder: Optional[str] = "",
    dag_tags: Optional[str] = ""
):

    dag_tags = ",".join(filter(None, [branch_name, branch_sha, dag_tags]))

    search_str = "with DAG("
    dags_path_local = "./airflow/dags"
    dags_path_efs = "/opt/airflow/dags"

    if branch_name == "main":
        replace_str = f'with DAG(additional_dag_tags="{dag_tags}",'
        dags_search_path = dags_path_local
        copy_source_path = dags_path_local + '/*'
    else:
        # slashes are not allowed, so replace all slashes with underscore
        branch_name = branch_name.replace("/", "_")
        replace_str = f'with DAG(dag_id_suffix="_{branch_name}",additional_dag_tags="{dag_tags}",'
        dags_search_path = f'{dags_path_local}/{dag_folder}'
        dags_path_efs = f'{dags_path_efs}/dev_env_only/{branch_name}/{dag_folder}'
        copy_source_path = f'{dags_search_path}/*'

        # create the folder on the efs volume if it does not exist
        os.system(f'if [ ! -d "{dags_path_efs}" ] ; then mkdir -p {dags_path_efs}; fi')

    # execute the string substitution which adds dag tags and/or modifies the dag id
    os.system(f"grep -rl '{dags_search_path}' -e '{search_str}' | xargs -I@ sed -i 's|{search_str}|{replace_str}|g' @;")

    # check for files that were deleted in git and remove them from the efs volume
    dircmpobj = dircmp(dags_search_path, dags_path_efs, ignore=['dev_env_only'])
    sync_deleted_files(dircmpobj, dags_path_efs)

    # copy the files to the efs
    os.system(f'cp -R {copy_source_path} {dags_path_efs}')


def sync_deleted_files(dircmpobj, path_efs, path=""):
    # check for files that were deleted in git and remove them from the efs volume
    for name in dircmpobj.right_only:
        filename = f"{path_efs}{path}/{name}"
        print(f"Deleting file: {filename}")
        os.system(f'rm -rf {filename}')

    # traverse all subdirectories recursively
    for k, v in dircmpobj.subdirs.items():
        delete_path = path + "/" + k
        sync_deleted_files(v, path_efs, delete_path)


def load_deployment_request(item):
    # load the contents of the deployment request from file on s3
    deploy_item = s3_client.get_object(Bucket=bucket_name, Key=item['Key'])
    deploy_item_body = str(deploy_item['Body'].next(), 'UTF-8')
    deploy_item_dict = json.loads(deploy_item_body)
    print("Deployment request:")
    print(deploy_item_dict)
    return deploy_item_dict


def delete_dags(branch_name, dag_folder):
    # replace all slashes in the branch name with underscores
    branch_name_no_slashes = branch_name.replace("/", "_")
    if dag_folder == "all":
        print(f"Processing delete request for branch: {branch_name}")
        os.system(f'rm -rf /opt/airflow/dags/dev_env_only/{branch_name_no_slashes}')
    else:
        print(f"Processing delete request for branch \"{branch_name}\" and dag folder \"{dag_folder}\"")
        os.system(f'rm -rf /opt/airflow/dags/dev_env_only/{branch_name_no_slashes}/{dag_folder}')

        # also delete the branch name directory if empty
        os.system(f'find /opt/airflow/dags/dev_env_only/{branch_name_no_slashes} -empty -type d -delete')


def archive_deployment_request(item, s3_prefix):
    # copy the deployment request file to a processed-requests prefix
    print("Archive the deployment request to \"processed-requests\" prefix.")
    s3_client.copy_object(
        Bucket=bucket_name,
        CopySource={'Bucket': bucket_name, 'Key': item['Key']},
        Key=item['Key'].replace(s3_prefix, "processed-requests")
    )

    # delete the original deployment request file
    s3_client.delete_object(Bucket=bucket_name, Key=item['Key'])


if __name__ == "__main__":
    main()
