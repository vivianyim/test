from python.create_resources import main
from python.tests.utils import assert_equal


def test_snowflake(setup):
    with open("octavia/values/destinations/test_snowflake.yaml", "w") as test_file:
        test_file.write(
            """
            _template: snowflake

            resource_name: test_snowflake

            role: test_role
            database: test_database
            username: test_username
            warehouse: test_warehouse
            password: "test_password"
            host: test_host
            schema: test_schema
            loading_method: test_loading_method
            encryption_type: test_encryption_type
            """
        )

    main()

    with open("airbyte/destinations/test_snowflake/configuration.yaml") as test_file:
        assert_equal(
            test_file,
            """
            resource_name: test_snowflake
            definition_type: destination
            definition_id: 424892c4-daac-4491-b35d-c6688ba547ba
            definition_image: airbyte/destination-snowflake
            definition_version: 0.4.31
            configuration:
              role: test_role
              database: test_database
              username: test_username
              warehouse: test_warehouse
              credentials:
                password: "test_password"
              host: test_host
              schema: test_schema
              loading_method:
                method: test_loading_method
                encryption:
                  encryption_type: test_encryption_type
            """,
        )
