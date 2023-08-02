import pytest


def mock_get_connections():
    return [
        {
            "name": "test_simple",
            "connectionId": "test_simple",
            "source": {"sourceId": "test_simple"},
        },
        {
            "name": "test_complex",
            "connectionId": "test_complex",
            "source": {"sourceId": "test_complex"},
        },
        {
            "name": "test_auto_sync",
            "connectionId": "test_auto_sync",
            "source": {"sourceId": "test_auto_sync"},
        },
    ]


def mock_get_refreshed_source(connection_id, source_id, source_id_to_streams):
    return {
        "test_simple": [
            {
                "stream": {"name": "test_simple"},
            }
        ],
        "test_complex": [
            {
                "stream": {"name": "test_complex"},
            }
        ],
        "test_auto_sync": [
            {
                "stream": {
                    "name": "test_stream",
                    "jsonSchema": {"properties": {"FIRST_NAME": {"type": "string"}, "LAST_NAME": {"type": "string"}}},
                    "namespace": "PUBLIC",
                },
                "config": {
                    "syncMode": "full_refresh",
                    "cursorField": ["ID"],
                    "destinationSyncMode": "overwrite",
                    "primaryKey": [["ID"]],
                },
            }
        ],
    }[connection_id]


@pytest.fixture
def setup(mocker):
    mocker.patch("python.create_resources.TEMPLATES_PATH", "octavia/templates")
    mocker.patch("python.create_resources.VALUES_PATH", "octavia/values")
    mocker.patch("python.create_resources.AIRBYTE_PATH", "airbyte")
    mocker.patch("python.create_resources.get_workspace_id", lambda: None)
    mocker.patch("python.create_resources.get_connections", mock_get_connections)
    mocker.patch("python.create_resources.get_refreshed_source", mock_get_refreshed_source)
