import logging
import os

previous_path = "/home/airbyte"
current_path = "/home/octavia-project/new/files/octavia/values"


def main():
    current_files = set()

    for path, _, file_names in os.walk(current_path):
        directory = path.split("/")[-1]

        for file_name in file_names:
            current_files.add(f"{directory}/{file_name.split('.')[0]}")

    previous_files = set()

    for path, directories, file_names in os.walk(previous_path):
        directory = path.split("/")[-1]

        if directory in {"connections", "sources", "destinations"}:
            for resource in directories:
                previous_files.add(f"{directory}/{resource}")

    for file_path in previous_files - current_files:
        logging.warning(f"deleting {previous_path}/{file_path}...")
        os.system(f"rm -rf {previous_path}/{file_path}")


if __name__ == "__main__":
    main()
