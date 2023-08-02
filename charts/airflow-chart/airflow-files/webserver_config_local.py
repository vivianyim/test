import yaml
from airflow.www.security import AirflowSecurityManager


class HyakLocalSecurityManager(AirflowSecurityManager):
    def __init__(self, appbuilder):
        super().__init__(appbuilder)

        with open("/opt/airflow/webserver_config.yaml") as stream:
            roles_config = yaml.safe_load(stream)

        roles_list = []

        for item in roles_config.get("roles", []):
            roles_list.append({"role": item["role"], "perms": []})

        self.bulk_sync_roles(roles_list)


SECURITY_MANAGER_CLASS = HyakLocalSecurityManager
