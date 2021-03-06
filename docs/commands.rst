Commands Reference
==================

Calling Envie
-------------

The ``envie`` script (or a :ref:`shell function <source-vs-exec>`) has three
calling forms -- two "shortcut" forms, and general/all-purpose form:


1. **find & activate**
^^^^^^^^^^^^^^^^^^^^^^

    ::

        envie [OPTIONS] [DIR] [KEYWORDS]

    The first form interactively activates the closest environment (relative to
    ``DIR``, or the current working directory, filtered by ``KEYWORDS``). If a
    single closest environment is detected, it is auto-activated. This calling
    form is basically an alias for ``chenv -v [DIR] [KEYWORDS]``. For options
    and details on environments discovery/selection, see :ref:`chenv <chenv>`
    below.


2. **run python script**
^^^^^^^^^^^^^^^^^^^^^^^^

    ::

        envie SCRIPT

    The second form is a shorthand for executing python scripts in the closest
    virtual environment, without the need for a manual env activation. It's
    identical in behaviour to ``envie python SCRIPT``
    (see :ref:`below <envie-python>`), but more convenient for a hash bang use:

        .. code-block:: python

            #!/usr/bin/env envie
            # Python script here will be executed in the closest virtual env


3. **general**
^^^^^^^^^^^^^^

    ::

        envie {create [ENV] | remove |
               list [DIR] [KEYWORDS] | find [DIR] [KEYWORDS] |
               python [SCRIPT] | run CMD |
               index | config | help | --help | --version}

    The third is a general form as it explicitly exposes all commands (for
    virtual env creation, removal, discovery, etc.) Most of these commands have a
    shorter alias you'll probably prefer in everyday use (like ``mkenv``, ``lsenv``,
    ``findenv``, ``chenv``, ``rmenv``, etc).



.. _chenv:

``envie`` / ``chenv`` - Interactively activate the closest virtual environment
------------------------------------------------------------------------------

::

    Interactively activate the closest Python virtual environment relative to DIR (or .)
    A list of the closest environments is filtered by KEYWORDS. Separate KEYWORDS with --
    if they start with a dash, or a dir with the same name exists.

    Usage:
        chenv [-1] [-f|-l] [-v] [-q] [DIR] [--] [KEYWORDS]
        envie ...

    Options:
        -1            activate only if a single closest env found, abort otherwise
        -f, --find    use only 'find' for search
        -l, --locate  use only 'locate' for search
        -v            be verbose: show info messages (path to activated env)
        -q            be quiet: suppress error messages

``chenv`` command uses :ref:`findenv <findenv>` to discover all virtual
environments in ``DIR``'s vicinity (searching below ``DIR``, then dir-by-dir up
until at least one virtual env is found), and then
:ref:`fuzzy-filters <fuzzy-filtering>` that list with a list of ``KEYWORDS``
given. If a single virtual environment is found, it's automatically activated.
If multiple environments are found, user chooses the environment from a list.

Examples
^^^^^^^^

Suppose you have a directory structure like this::

    work
    ├── plucky
    │   ├── env
    │   │   ├── dev
    │   │   └── prod
    │   └── src
    ├── jsonplus
    │   ├── pythonenv
    │   ├── src
    │   └── var

Starting from base directory ``work``, we can activate ``jsonplus`` environment with:

.. code-block:: bash

    ~/work$ envie js
    Activated virtual environment at 'jsonplus/pythonenv'.

Or, starting from a project root at ``work/jsonplus/src``, just type:

.. code-block:: bash

    ~/work/jsonplus/src$ envie
    Activated virtual environment at '../pythonenv'.

When your query matches multiple environments, you'll get a prompt:

.. code-block:: bash

    ~/work$ envie plucky
    1) plucky/env/dev
    2) plucky/env/prod
    #? 2
    Activated virtual environment at 'plucky/env/prod'.

But you can avoid it by being a bit more specific:

.. code-block:: bash

    ~/work$ envie prrrod
    Activated virtual environment at 'plucky/env/prod'.

(Notice we had a typo here, ``prrrod``.)



.. _mkenv:

``envie create`` / ``mkenv`` - Create a new virtual environment
---------------------------------------------------------------

::

    Create Python (2/3) virtual environment in DEST_DIR based on PYTHON.

    Usage:
        mkenv [-2|-3|-e PYTHON] [-r PIP_REQ] [-p PIP_PKG] [-a] [-t] [DEST_DIR] [-- ARGS_TO_VIRTUALENV]
        mkenv2 [-r PIP_REQ] [-p PIP_PKG] [-a] [-t] [DEST_DIR] ...
        mkenv3 [-r PIP_REQ] [-p PIP_REQ] [-a] [-t] [DEST_DIR] ...
        envie create ...

    Options:
        -2, -3      use Python 2, or Python 3
        -e PYTHON   use Python accessible with PYTHON name,
                    like 'python3.5', or '/usr/local/bin/mypython'.
        -r PIP_REQ  install pip requirements in the created virtualenv,
                    e.g. '-r dev-requirements.txt'
        -p PIP_PKG  install pip package in the created virtualenv,
                    e.g. '-p "Django>=1.9"', '-p /var/pip/pkg', '-p "-e git+https://gith..."'
        -a          autodetect and install pip requirements
                    (search for the closest 'requirements.txt' and install it)
        -t          create throw-away env in /tmp
        -v[v]       be verbose: show virtualenv&pip info/debug messages
        -q[q]       be quiet: suppress info/error messages


This command creates a new Python virtual environment (using the ``virtualenv``
tool) in the optionally supplied destination directory ``DEST_DIR``. Default
destination is ``env`` in the current directory, but that default can be
overriden via :ref:`config variable <config-vars>` ``_ENVIE_DEFAULT_ENVNAME``).

The default Python interpreter (executable used in a new virtual env) is defined
with the config variable ``_ENVIE_DEFAULT_PYTHON`` and if not specified
otherwise, it defaults to system ``python``. Python executable can always be
explicitly specified with ``-e`` parameter, e.g: ``-e /path/to/python``, or ``-e
python3.5``. The shorthand flags ``-2`` and ``-3`` will select the default
Python 2 and Python 3 interpreters available, respectively.

.. tip::
    You can use aliases ``mkenv2`` and ``mkenv3`` instead of ``mkenv -2`` and
    ``mkenv -3``, respectively.

To (pre-)install a set of Pip packages (requirements) in the virtual env
created, you can use ``-r`` and ``-p`` options, like: ``-r requirements.txt``
and ``-p package/archive/url``. The former will install requirements from a
given file (or files, if option is repeated), and the latter will install a
specific Pip package (or packages, if option repeated). The ``-p`` option
supports all pip-supported formats: requirement specifier, VCS package URL,
local package path, or archive path/URL:

    - ``-p requests``, ``-p "jsonplus>=0.6"``,
    - ``-p /path/to/my/local/package``,
    - ``-p "-e git+https://github.com/randomir/plucky.git#egg=plucky"``.

If a standard name for requirements file is used in your project
(``requirements.txt``), you can use the ``-a`` flag to find and auto-install the
closest requirements below the CWD.

Throw-away or temporary environment is created with ``-t`` flag. The location
and name of the virtual environment are chosen randomly with the ``mktemp``
(something like ``/tmp/tmp.4Be8JJ8OJb``). When done with hacking in a throw-away
env, simply destroy it with ``rmenv -f``.

.. tip::
    Throw-away environments are great for short-lived experiments, for example:

    .. code-block:: bash

        $ mkenv3 -t -p requests -p plucky && python && rmenv -fv
        Creating Python virtual environment in '/tmp/tmp.ial0H5kZvu'.
        Using Python 3.5.2+ (/usr/bin/python3).
        Virtual environment ready.
        Installing Pip requirements: requests plucky
        Pip requirements installed.
        Python 3.5.2+ (default, Sep 22 2016, 12:18:14) 
        [GCC 6.2.0 20160927] on linux
        Type "help", "copyright", "credits" or "license" for more information.
        >>> import requests, plucky
        >>> plucky.pluck(requests.get('https://api.github.com/users/randomir/repos').json(), 'name')
        ['blobber', 'dendritic-growth-model', 'envie', 'joe', 'jsonplus', 'python-digitalocean', ...]
        >>> exit()
        VirtualEnv removed: /tmp/tmp.ial0H5kZvu


Examples
^^^^^^^^

Starting from a base directory ``~/work``, let's create Python 2 & 3 virtual
environments for our new project ``yakkety``:

.. code-block:: bash

    ~/work$ mkenv3 yakkety/env/dev
    Creating Python virtual environment in 'yakkety/env/dev'.
    Using Python 3.5.2+ (/usr/bin/python3).
    Virtual environment ready.
    (dev) ~/work$

    (dev) ~/work$ mkenv2 yakkety/env/dev
    Creating Python virtual environment in 'yakkety/env/prod'.
    Using Python 2.7.12+ (/usr/bin/python2).
    Virtual environment ready.
    (prod) ~/work$

Note here (1) directory structure is recursively created, and (2) active
environment does not interfere with Python interpreter discovery.

We can create a temporary environment with dev version of package installed from
GitHub source:

.. code-block:: bash

    $ mkenv -tp "-e git+https://github.com/randomir/plucky.git#egg=plucky"



.. _rmenv:

``envie remove`` / ``rmenv`` - Delete the active virtual environment
--------------------------------------------------------------------

::

    Remove (delete) the base directory of the active virtual environment.

    Usage:
        rmenv [-f] [-v]
        envie remove ...

    Options:
        -f    force; don't ask for permission
        -v    be verbose

``rmenv`` will remove a complete virtual env directory tree of the active
environment (defined with shell variable ``$VIRTUAL_ENV``), or fail otherwise.
To avoid prompting for confirmation, supply the ``-f`` flag, and to print the
directory removed, use the ``-v`` switch.



.. _lsenv:

``envie list`` / ``lsenv [DIR]`` - List virtual environments below ``DIR``
--------------------------------------------------------------------------

::

    Find and list all virtualenvs under DIR, optionally filtered by KEYWORDS.

    Usage:
        lsenv [-f|-l] [DIR [AVOID_SUBDIR]] [--] [KEYWORDS]
        envie list ...

    Options:
        -f, --find    use only 'find' for search
        -l, --locate  use only 'locate' for search
                      (by default, try find for 0.4s, then failback to locate)
        -v            be verbose: show info messages
        -q            be quiet: suppress error messages


``envie list`` searches down only, starting in ``DIR`` (defaults to ``.``).
The search method is defined with config, but it can be overriden with ``-f``
and ``-l`` to force ``find`` or ``locate`` methods respectively.

.. _fuzzy-filtering:

**Fuzzy filtering.** To narrow down the list of virtualenv paths, you can filter it by supplying ``KEYWORDS``.
Filtering algorithm is not strict and exclusive (like grep), but fuzzy and typo-forgiving.

It works like this: (1) all virtualenv paths discovered are split into directory components;
(2) we try to greedily match all keywords to components by maximum similarity score;
(3) paths are sorted by total similarity score; (4) the best matches are passed-thru -- if
there's a tie, all best matches are printed.

When calculating similarity between directory name (path component) and a keyword, we
assign: (1) maximum weight to a complete match (identity), (2) smaller, but still high, weight
to a prefix match, and (3) the smallest (and variable) weight to a diff-metric similarity.


Examples
^^^^^^^^

For an example, suppose you have a directory tree like this one::

    ├── trusty-tahr
    │   ├── dev
    │   └── prod
    ├── zesty-zapus
    │   ├── dev
    │   └── prod

To get all environments containing ``dev`` word:

.. code-block:: bash

    $ lsenv dev
    trusty-tahr/dev
    zesty-zapus/dev

To get all ``trusty`` envs, you can either filter by ``trusty`` (or ``tahr``, or ``hr``, or ``t``):

.. code-block:: bash

    $ lsenv hr
    trusty-tahr/dev
    trusty-tahr/prod

or, list envs in ``./trusty-tahr`` dir:

.. code-block:: bash

    $ lsenv ./trusty-tahr
    trusty-tahr/dev
    trusty-tahr/prod

Combine it:

.. code-block:: bash

    $ lsenv trusty-tahr pr
    trusty-tahr/prod

or with several keywords:

.. code-block:: bash

    $ lsenv z d
    zesty-zapus/dev



.. _findenv:

``envie find`` / ``findenv [DIR]`` - Find the closest virtual environment around ``DIR``
----------------------------------------------------------------------------------------

::

    Find and list all virtualenvs below DIR, or above if none found below.
    List of virtualenv paths returned is optionally filtered by KEYWORDS.

    Usage:
        findenv [-f|-l] [DIR] [--] [KEYWORDS]
        envie find ...

    Options:
        -f, --find    use only 'find' for search
        -l, --locate  use only 'locate' for search
                      (by default, try find for 0.4s, then failback to locate)
        -v            be verbose: show info messages
        -q            be quiet: suppress error messages


Similar to ``envie list``, but with a key distinction: if no environments are
found below the starting ``DIR``, the search is being expanded -- level by level
up -- until at least one virtual environment is found.

Description of discovery methods (``--find``/``--locate``), as well as keywords
filtering behaviour given for ``envie list``/``lsenv`` apply here also.



.. _envie-python:

``envie python`` / ``envie SCRIPT`` - Run Python SCRIPT in the closest virtual environment
------------------------------------------------------------------------------------------

Run a Python SCRIPT, or an interactive Python interpreter session in the
closest virtual environment.
Three calling forms are supported:

``envie SCRIPT [ARGS]``
    The ``SCRIPT`` is explicitly executed with ``python`` from the closest
    environment. If multiple environments are found in the vicinity, operation is
    aborted.

``envie python SCRIPT [ARGS]``
    Identical in behaviour to the above, but more explict.

``envie python``
    A special no-script case, where an interactive Python session is started instead.

.. hint::
    This command is basically a shortcut for::

        chenv -1v && exec python [SCRIPT [ARGS]]

Examples
^^^^^^^^

::

    envie manage.py migrate

    envie python tests.py --fast



.. _envie-run:

``envie run CMD`` - Run CMD in the closest virtual env
------------------------------------------------------

As a generalization of the ``envie python`` command above, this command will run
*anything that can be run*, in the closest virtual environment. The ``CMD`` can
be an **executable** (script) file, shell **command**, shell **builtin**,
**alias**, or a shell **function**.

``envie run CMD [ARGS]``
    Runs any executable construct ``CMD``, optionally passing-thru arguments
    ``ARGS``, inside the closest virtual environment. Fails when multiple
    environments are found in the vicinity.

.. hint::
    Similarly to ``envie python``, this command is basically a shortcut for::

        chenv -1v && exec CMD [ARGS]

Examples
^^^^^^^^

We can emulate the ``envie python`` command with::

    envie run python /path/to/my/script

but also run shell functions which are sensitive to the Python virtual env::

    envie run my_function

Moreover, we can run the apropriate ``python`` in the command mode::

    envie run python -c 'import os; print(os.getenv("VIRTUAL_ENV"))'



.. _envie-config:

``envie config`` - Configure Envie
-----------------------------------

Listed here for completeness, configuration is described in detail under the
:ref:`setup-config` section.



.. _envie-index:

``envie index`` - (Re-)Index Environments
-----------------------------------------

If Envie is configured to use ``locate`` for environments discovery, index can
be rebuilt (updated via ``updatedb``) with ``envie index``. For more on ``find``
vs. ``locate`` methods, see :ref:`here <find-vs-locate>`.



.. _envie-tmp:

``envie-tmp SCRIPT`` - Run SCRIPT in a temporary environment
------------------------------------------------------------

::

    Create a new temporary (throw-away) virtual environment, install requirements
    specified, run the SCRIPT, and destroy the environment afterwards.

    Usage:
        envie-tmp SCRIPT

    Hashbang examples:

     1) no requirements (mkenv -t)

        #!/usr/bin/env envie-tmp

     2) installs reqs from the closest "requirements.txt" (mkenv -ta):

        #!/usr/bin/env envie-tmp
        # -*- requirements: auto -*-

     3) installs reqs from the specific Pip requirements files (relative to SCRIPT's dir)
        (mkenv -t -r REQ ...):

        #!/usr/bin/env envie-tmp
        # -*- requirements: ../base-requirements.txt ./dev-requirements.txt -*-

     4) specify the Python version to use, and install some Pip packages
        (mkenv -t -e PYTHON -p PKG ...):

        #!/usr/bin/env envie-tmp
        # -*- python-version: python3 -*-
        # -*- packages: plucky requests>=2.0 flask==0.12 -e/path/to/pkg -e. -*-
