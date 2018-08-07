# Application's configuration

Configuration files should reside in ``configs`` directory and be a shell scripts.

## Configuration file naming

File name should contains application name for which this configuration is responsible. Format:

```shell
$appname.config.sh
```

E.g.:

* Consul: ``consul.config.sh``.
* serviceone: ``serviceone.config.sh``.
* dbserializer: ``dbserializer.config.sh``.

## Format

### Variables

All variables names should be capitalized like:

```shell
APPNAME_VARNAME
```

E.g.:

* ``CONSUL_URL`` - link to Consul's kubernetes configuration repository.

This is required due to shell's (and Bash) sourcing nature - it will overwrite all variables on script sourcing.

If variable is used only within specific configuration file - then it should be named like ``_$APPNAME_VARNAME``, e.g. ``_CONSUL_HOW_TO_RULE_OVER_SERVICES``.

### Functions names

All functions names should be in lower case and names should be created accroding to this scheme:

```shell
appname_funcname
```

E.g.:

* ``consul_deploy`` - Consul deploy.
* ``core_auth_office_deploy`` - auth service deploying in kubernetes namespace "office".

#### External and internal functions

Shell (and Bash) have no syntax sugar like in Go (exported are in upper case, unexported in lower case), there are a logical agreement:

1. If function **should be called outside of file**, then name it like ``$name_action`` where ``$name`` is a name of application, configuration or library.
2. If function **shouldn't be called outside of file**, then name it like ``_$name_action``.

Rules are pretty same as for variables names defined before.

## Need-to-have variables

* ``$APPNAME_INSTALLATION_TYPE`` - installation type for Kubernetes sources. Currently only ``git`` is supported, more things ToDo.
* ``$APPNAME_NAME`` - application name to use, e.g., while printing to console or when trying to access variables.
* ``$APPNAME_URL`` - URL from which Kubernetes configuration should be fetched.