import os
import sys
import re

from datetime import datetime
from configparser import ConfigParser
from typeguard import typechecked
from collections import namedtuple

# prepare NOW substitution
now = datetime.now()
os.environ["NOW"] = str(now)
now_re = re.compile(r"\${NOW:([^}]*)}")

# read the ini file, recursing into the includes to build the final dictionary
@typechecked
def config_reader(conf_file: str, top_level: str = "") -> ConfigParser:
    if not os.access(conf_file, os.R_OK):
        if top_level:
            sys.exit(f"Config file '{conf_file}' among the includes of '{top_level}' "
                      "does not exist or not readable")
        else:
            sys.exit(f"Config file '{conf_file}' does not exist or not readable")
    config = ConfigParser(allow_no_value=True, interpolation=None, delimiters=("="))
    config.optionxform = str
    config.read(conf_file)
    if not top_level:
        top_level = conf_file
    if "base" in config and "includes" in config["base"]:
        for include in config["base"]["includes"].split(","):
            if (include := include.strip()):
                inc_conf = config_reader(f"{os.path.dirname(conf_file)}/{include}", top_level)
                for section in inc_conf.sections():
                    if section not in config.sections():
                        config[section] = inc_conf[section]
                    else:
                        conf_section = config[section]
                        inc_section = inc_conf[section]
                        for key in inc_section:
                            if key not in conf_section:
                                conf_section[key] = inc_section[key]
    return config

# replace ${NOW:...} pattern with appropriately formatted datetime string
@typechecked
def replace_now(mt: re.Match) -> str:
    return now.strftime(mt.group(1))

# replace the environment variables and the special ${NOW:...} from all values
@typechecked
def config_postprocess(config: ConfigParser) -> ConfigParser:
    for section in config.sections():
        conf_section = config[section]
        for key in conf_section:
            if (val := conf_section[key]):
                new_val = re.sub(now_re, replace_now, val)
                new_val = os.path.expandvars(new_val)
                if new_val is not val:
                    conf_section[key] = new_val
    return config

# print the entire contents of a ConfigParser as a nested dictionary
@typechecked
def print_config(config: ConfigParser) -> None:
    print({section: dict(config[section]) for section in config.sections()})

# colors for printing in terminal
TermColors = namedtuple("TermColors",
        "black red green orange blue purple cyan lightgray reset bold disable")
fgcolor = TermColors("\033[30m", "\033[31m", "\033[32m", "\033[33m", "\033[34m",
        "\033[35m", "\033[36m", "\033[37m", "\033[00m", "\033[01m", "\033[02m")
bgcolor = TermColors("\033[40m", "\033[41m", "\033[42m", "\033[43m", "\033[44m",
        "\033[45m", "\033[46m", "\033[47m", "\033[00m", "\033[01m", "\033[02m")
