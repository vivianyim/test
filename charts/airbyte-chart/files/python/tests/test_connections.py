import os

from python.create_resources import main
from python.tests.utils import assert_equal

os.environ["TEST_ENV_VAR_KEY"] = "TEST_ENV_VAR_VALUE"


def test_simple(setup):
    with open("octavia/values/connections/test_simple.yaml", "w") as test_file:
        test_file.write(
            """
            _template: connection

            resource_name: test_simple

            source: test_source
            destination: test_destination
            streams:
              - name: ${TEST_ENV_VAR_KEY}
            """
        )

    main(schema_refresh=True)

    with open("airbyte/connections/test_simple/configuration.yaml") as test_file:
        assert_equal(
            test_file,
            """
            resource_name: test_simple
            definition_type: connection
            source_configuration_path: sources/test_source/configuration.yaml
            destination_configuration_path: destinations/test_destination/configuration.yaml
            configuration:
              status: inactive
              skip_reset: true
              namespace_definition: destination
              namespace_format: ${SOURCE_NAMESPACE}
              prefix: ""
              schedule_type: manual
              sync_catalog:
                streams:
                  - config:
                      cursor_field:
                        []
                      destination_sync_mode: overwrite
                      primary_key:
                        []
                      selected: true
                      sync_mode: full_refresh
                    stream:
                      json_schema:
                        properties: {}
                      name: TEST_ENV_VAR_VALUE
                      supported_sync_modes:
                        - full_refresh
                        - incremental
            """,
        )


def test_complex(setup):
    with open("octavia/values/connections/test_complex.yaml", "w") as test_file:
        test_file.write(
            """
            _template: connection

            resource_name: test_complex

            source: test_source
            destination: test_destination
            status: test_status
            skip_reset: test_skip_reset
            namespace_definition: test_namespace_definition
            namespace_format: test_namespace_format
            prefix: test_prefix
            schedule_type: test_schedule_type
            time_unit: test_time_unit
            units: test_units
            streams:
              - name: test_name
                namespace: test_namespace
                primary_key:
                  - test_primary_key
                cursor_field: test_cursor_field
                sync_mode: test_sync_mode
                destination_sync_mode: test_destination_sync_mode
                properties:
                  test_property_key: test_property_value
            """
        )

    main(schema_refresh=True)

    with open("airbyte/connections/test_complex/configuration.yaml") as test_file:
        assert_equal(
            test_file,
            """
            resource_name: test_complex
            definition_type: connection
            source_configuration_path: sources/test_source/configuration.yaml
            destination_configuration_path: destinations/test_destination/configuration.yaml
            configuration:
              status: test_status
              skip_reset: test_skip_reset
              namespace_definition: customformat
              namespace_format: test_namespace_format
              prefix: test_prefix
              schedule_type: test_schedule_type
              sync_catalog:
                streams:
                  - config:
                      cursor_field:
                        - test_cursor_field
                      destination_sync_mode: test_destination_sync_mode
                      primary_key:
                        - - test_primary_key
                      selected: true
                      sync_mode: test_sync_mode
                    stream:
                      json_schema:
                        properties: {'test_property_key': 'test_property_value'}
                      name: test_name
                      namespace: test_namespace
                      supported_sync_modes:
                        - full_refresh
                        - incremental
            """,
        )


def test_auto_sync(mocker, setup):
    with open("octavia/values/connections/test_auto_sync.yaml", "w") as test_file:
        test_file.write(
            """
            _template: connection

            resource_name: test_auto_sync

            source: test_source
            destination: test_destination
            streams:
              - name: test_stream
            """
        )

    main(schema_refresh=True)

    with open("airbyte/connections/test_auto_sync/configuration.yaml") as test_file:
        assert_equal(
            test_file,
            """
            resource_name: test_auto_sync
            definition_type: connection
            source_configuration_path: sources/test_source/configuration.yaml
            destination_configuration_path: destinations/test_destination/configuration.yaml
            configuration:
              status: inactive
              skip_reset: true
              namespace_definition: destination
              namespace_format: ${SOURCE_NAMESPACE}
              prefix: ""
              schedule_type: manual
              sync_catalog:
                streams:
                  - config:
                      cursor_field:
                        - ID
                      destination_sync_mode: overwrite
                      primary_key:
                        - - ID
                      selected: true
                      sync_mode: full_refresh
                    stream:
                      json_schema:
                        properties: {'FIRST_NAME': {'type': 'string'}, 'LAST_NAME': {'type': 'string'}}
                      name: test_stream
                      namespace: PUBLIC
                      supported_sync_modes:
                        - full_refresh
                        - incremental
            """,
        )
