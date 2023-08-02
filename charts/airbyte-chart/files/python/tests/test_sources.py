from python.create_resources import main
from python.tests.utils import assert_equal


def test_postgres(setup):
    with open("octavia/values/sources/test_postgres.yaml", "w") as test_file:
        test_file.write(
            """
            _template: postgres

            resource_name: test_postgres

            host: test_host
            port: test_port
            schemas: test_schemas
            database: test_database
            username: test_username
            password: "test_password"
            tunnel_method: test_tunnel_method
            replication_method: test_replication_method
            """
        )

    main()

    with open("airbyte/sources/test_postgres/configuration.yaml") as test_file:
        assert_equal(
            test_file,
            """
            resource_name: test_postgres
            definition_type: source
            definition_id: decd338e-5647-4c0b-adf4-da0e75f5a750
            definition_image: airbyte/source-postgres
            definition_version: 0.4.31
            configuration:
              host: test_host
              port: test_port
              schemas: test_schemas
              database: test_database
              username: test_username
              password: "test_password"
              tunnel_method:
                tunnel_method: test_tunnel_method
              replication_method:
                method: test_replication_method
            """,
        )
