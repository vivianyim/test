import os
import shutil

source = "/home/octavia-project/old"
destination = "/home/octavia-project/new"


def main():
    for file_path_old in os.listdir(source):
        file_path_new = file_path_old.replace("-x-", "/")
        *sub_path, file_name = file_path_new.split("/")

        if file_name.startswith("."):
            continue

        sub_path = "/".join(sub_path)
        os.makedirs(f"{destination}/{sub_path}", exist_ok=True)
        shutil.copy(f"{source}/{file_path_old}", f"{destination}/{sub_path}/{file_name}")


if __name__ == "__main__":
    main()
