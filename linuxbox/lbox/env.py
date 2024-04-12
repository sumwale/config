import os

import argparse
import getpass
import typing

from configparser import SectionProxy
from typeguard import typechecked

class Environ:
    @typechecked
    def __init__(self, args: argparse.Namespace, box_name: str):
        # prepare for the additional environment variables and NOW substitution
        os.environ["DISTRIBUTION_NAME"] = args.distribution
        os.environ["CONTAINER_NAME"] = box_name
        self._home_dir = os.environ['HOME']
        self._box_name = box_name
        # user data directory is $HOME/.local/share/linuxbox
        self._data_subdir = ".local/share/linuxbox"
        self._container_dir =  f"{self._home_dir}/{self._data_subdir}/{box_name}"
        os.environ["CONTAINER_DIR"] = self._container_dir
        self._config_dirs = [f"{self._home_dir}/.config/linuxbox", "/etc/linuxbox"]
        # local user home might be in a different location than /home but target user in the
        # container will always be in /home as ensured by lbox/entrypoint.py script
        self._target_home = "/home/" + getpass.getuser()
        os.environ["TARGET_HOME"] = self._target_home

    @property
    @typechecked
    def home(self) -> str:
        return self._home_dir

    @property
    @typechecked
    def target_home(self) -> str:
        return self._target_home

    @property
    @typechecked
    def box_name(self) -> str:
        return self._box_name

    @property
    @typechecked
    def data_subdir(self) -> str:
        return self._data_subdir

    @property
    @typechecked
    def container_dir(self) -> str:
        return self._container_dir

    @property
    @typechecked
    def config_dirs(self) -> list[str]:
        return self._config_dirs

@typechecked
def add_env_option(args: list[str], envvar: str, envval: typing.Optional[str] = None) -> None:
    if envval is None:
        args.append(f"-e={envvar}")
    else:
        args.append(f"-e={envvar}={envval}")

@typechecked
def process_env_section(env_section: SectionProxy, args: list[str]) -> None:
    for key in env_section:
        add_env_option(args, key, env_section[key])
