import json
import logging
import os
import sys
from time import sleep

import jinja2
import requests
import yaml

TEMPLATES_PATH = "/home/octavia-project/new/files/octavia/templates"
VALUES_PATH = "/home/octavia-project/new/files/octavia/values"
AIRBYTE_PATH = "/home/airbyte"


def api_call(endpoint, payload=None, max_retries=6):
    retry_count = 0

    while retry_count <= max_retries + 1:
        try:
            response = requests.post(
                url=f"http://{os.environ.get('AIRBYTE_URL')}/api/v1/{endpoint}",  # NOSONAR
                headers={"accept": "application/json", "content-type": "application/json"},
                data=json.dumps(payload),
            )

            if response.status_code == 200:
                return response.json()

            if response.status_code in {504}:  # Retry only these status codes.
                raise Exception(response.status_code)

            logging.warning(f"<REQUEST>: {endpoint} | <PAYLOAD>: {payload} | <ERROR>: {response.status_code}")

            return {}
        except Exception as exception:
            if retry_count > max_retries:
                seconds = 0
                retry_message = "RETRIES EXHAUSTED"
            else:
                seconds = 2**retry_count
                retry_message = f"RETRYING IN {seconds} SECONDS..."

            logging.warning(f"<REQUEST>: {endpoint} | <PAYLOAD>: {payload} | <ERROR>: {exception} {retry_message}")

            sleep(seconds)

        retry_count += 1

    return {}


def get_workspace_id():
    return (
        api_call(
            "workspaces/list",
        )
        .get("workspaces", [{}])[0]
        .get("workspaceId")
    )


def get_connections():
    return api_call(
        "web_backend/connections/list",
        {
            "workspaceId": get_workspace_id(),
        },
    ).get("connections", [])


def get_refreshed_source(connection_id, source_id, source_id_to_streams):
    if source_id not in source_id_to_streams:
        source_id_to_streams[source_id] = (
            api_call(
                "web_backend/connections/get",
                {
                    "connectionId": connection_id,
                    "withRefreshedCatalog": True,
                },
            )
            .get("syncCatalog", {})
            .get("streams", [])
        )

    return source_id_to_streams[source_id]


def map_streams(streams):
    mapped_streams = []

    for stream in streams:
        mapped_streams.append(
            {
                "cursor_field": (stream.get("config", {}).get("cursorField") or [None])[0],
                "primary_key": [primary_key[0] for primary_key in stream.get("config", {}).get("primaryKey", [])],
                "properties": stream.get("stream", {}).get("jsonSchema", {}).get("properties"),
                "name": stream.get("stream", {}).get("name"),
                "namespace": stream.get("stream", {}).get("namespace"),
            }
        )

    return mapped_streams


def update_streams_helper(dict1, dict2):
    for key in dict2:
        if not dict1.get(key):
            dict1[key] = dict2[key]
        elif isinstance(dict1[key], dict) and isinstance(dict2[key], dict):
            update_streams_helper(dict1[key], dict2[key])


def update_streams(streams1, streams2):
    dict1 = {stream["name"]: stream for stream in streams1}
    dict2 = {stream["name"]: stream for stream in streams2}

    for key in dict1.keys() & dict2.keys():
        update_streams_helper(dict1[key], dict2[key])


def expandvars(resource_values):
    if isinstance(resource_values, str):
        return os.path.expandvars(resource_values)

    if isinstance(resource_values, dict):
        return {key: expandvars(value) for key, value in resource_values.items()}

    if isinstance(resource_values, list):
        return [expandvars(value) for value in resource_values]

    return resource_values


def main(schema_refresh=False):
    environment = jinja2.Environment(loader=jinja2.FileSystemLoader(TEMPLATES_PATH))  # NOSONAR
    environment.filters["getenv"] = lambda var: os.getenv(var)

    connections = get_connections()
    connection_name_to_connection_id = {connection["name"]: connection["connectionId"] for connection in connections}
    connection_id_to_source_id = {connection["connectionId"]: connection["source"]["sourceId"] for connection in connections}
    source_id_to_streams = {}

    for file_paths, _, file_names in os.walk(VALUES_PATH):
        resource_type = file_paths.split("/")[-1]

        for resource_name_raw in file_names:
            resource_values = yaml.safe_load(open(f"{VALUES_PATH}/{resource_type}/{resource_name_raw}"))

            if resource_type == "connections":
                connection_id = connection_name_to_connection_id.get(resource_values["resource_name"])

                if schema_refresh:
                    source_id = connection_id_to_source_id.get(connection_id)

                    if not connection_id or not source_id:
                        continue

                    refreshed_connection_streams = get_refreshed_source(connection_id, source_id, source_id_to_streams)

                    if not refreshed_connection_streams:
                        continue

                    update_streams(resource_values["streams"], map_streams(refreshed_connection_streams))
                elif connection_id:
                    continue

            new_path = f"{AIRBYTE_PATH}/{resource_type}/" + resource_name_raw.split(".")[0]
            os.makedirs(new_path, exist_ok=True)

            with open(f"{new_path}/configuration.yaml", "w") as stream:
                resource_values = expandvars(resource_values)
                stream.write(environment.get_template(f"{resource_type}/{resource_values['_template']}.yaml").render(resource_values))


if __name__ == "__main__":
    main(schema_refresh="--schema-refresh" in sys.argv)
