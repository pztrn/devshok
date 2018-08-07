# Exit codes

Use this table to figure out what's wrong.

| Код | Описание |
| --- | -------- |
| 1   | Unable to load module (application, configuration, library). Last message should specify concrete error. |
| 2   | Required binary wasn't found. Last message should specify what binary exactly. |
| 3   | Normal wrapper was used instead of devshok-osx. |
| 4   | devshok-osx used on Linux. |
| 5   | Requested application cannot continue because ``app_main`` function is missing. |
| 6   | Unable to determine IP address of minikube's VM. |
| 7   | Application's configuration is unusable due to missing required variables (see [configuration description](configs.md)). |
| 8   | Application's configuration has no ``$appname_deploy`` function. |
| 9   | Unsupported installation type. Last message should specify what method was passed. |
| 10  | Specific deployment isn't supported by application's configuration (for use with application's configurations). |
| 11  | Empty deployment type isn't supported by application's configuration (for use with application's configurations). |
| 12  | Application's configuration wasn't found. Last message should specify application's name. |
| 13  | Unsupported platform. |
| 14  | User declined Brew, Bash or coreutils installation (macOS specific). |
| 15  | VirtualBox isn't installed (Linux specific). |