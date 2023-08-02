import yaml
from airflow.models import DagBag
from airflow.models.connection import Connection
from airflow.security import permissions
from airflow.www.security import AirflowSecurityManager
from flask_appbuilder.security.manager import AUTH_LDAP

AUTH_LDAP_BIND_PASSWORD = f"{Connection.get_connection_from_secrets('jumpcloud_ldap').get_password()}"
AUTH_LDAP_BIND_USER = "uid=hyak-serviceaccount,ou=Users,o=5e7bac54dc407b0e14d9095f,dc=jumpcloud,dc=com"
AUTH_LDAP_SEARCH = "ou=Users,o=5e7bac54dc407b0e14d9095f,dc=jumpcloud,dc=com"
AUTH_LDAP_SERVER = "ldap://ldap.jumpcloud.com:389"
AUTH_ROLES_MAPPING = {}
AUTH_ROLES_SYNC_AT_LOGIN = True
AUTH_TYPE = AUTH_LDAP
AUTH_USER_REGISTRATION = True

BASIC_PERMISSIONS = [
    (permissions.ACTION_CAN_ACCESS_MENU, permissions.RESOURCE_BROWSE_MENU),
    (permissions.ACTION_CAN_ACCESS_MENU, permissions.RESOURCE_DAG_RUN),
    (permissions.ACTION_CAN_ACCESS_MENU, permissions.RESOURCE_TASK_INSTANCE),
    (permissions.ACTION_CAN_CREATE, permissions.RESOURCE_DAG_RUN),
    (permissions.ACTION_CAN_CREATE, permissions.RESOURCE_TASK_INSTANCE),
    (permissions.ACTION_CAN_DELETE, permissions.RESOURCE_DAG_RUN),
    (permissions.ACTION_CAN_DELETE, permissions.RESOURCE_TASK_INSTANCE),
    (permissions.ACTION_CAN_EDIT, permissions.RESOURCE_DAG_RUN),
    (permissions.ACTION_CAN_EDIT, permissions.RESOURCE_TASK_INSTANCE),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_DAG_CODE),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_DAG_RUN),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_DAG_WARNING),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_IMPORT_ERROR),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_TASK_INSTANCE),
    (permissions.ACTION_CAN_READ, permissions.RESOURCE_TASK_LOG),
]


class HyakSecurityManager(AirflowSecurityManager):
    def __init__(self, appbuilder):
        super().__init__(appbuilder)

        with open("/opt/airflow/webserver_config.yaml") as stream:
            webserver_config = yaml.safe_load(stream)

        roles = []

        for role in webserver_config.get("roles", []):
            perms = []

            for dag_id, dag in DagBag(include_examples=False).dags.items():
                for tag in role["tags"]:
                    if tag["tag"] not in dag.tags:
                        continue

                    for perm in tag["perms"]:
                        perms.append((perm, f"{permissions.RESOURCE_DAG_PREFIX}{dag_id}"))

            roles.append({"role": role["role"], "perms": BASIC_PERMISSIONS + perms})

        self.bulk_sync_roles(roles)

        for common_name in webserver_config.get("common_names", []):
            AUTH_ROLES_MAPPING[f"cn={common_name['common_name']},{AUTH_LDAP_SEARCH}"] = common_name["roles"]


SECURITY_MANAGER_CLASS = HyakSecurityManager
