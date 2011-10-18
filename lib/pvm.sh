# PVM: PHP Version Manager


function pvm {
  [ $# -eq 0 ] && pvm help && return 1

  case $1 in

  "h" | "help" )
    [ $# -ne 1 ] && pvm help && return 1

    echo "Usage:"
    echo "  pvm help"
    echo "  pvm list"
    echo "  pvm install <version> [<name> <arg> ...]"
    echo
    ;;

  "l" | "list" )
    [ $# -ne 1 ] && pvm help && return 1

    [ ! -d "$PVM_DIR" ]      && pvm __export_pvm_dir
    [ ! -d "$PVM_DIR" ]      && return 1
    [ ! -d "$PVM_DIR/phps" ] && pvm __e "Nothing was installed" && return 0

    versions=$(cd "$PVM_DIR/phps" ; ls -d *)
    for version in $versions
    do
      echo "- $version"
    done
    
    ;;
    
  "use" )
    [ $# -ne 2 ] && pvm help && return 1
    
    [ ! -d "$PVM_DIR" ] && pvm __export_pvm_dir
    [ ! -d "$PVM_DIR" ] && return 1
    
    [ "$PVM_VERSION" == "" ] && pvm __export_pvm_version
    
    VERSION=`pvm __parse_version $2`
    [ "$VERSION" == "" ] && pvm __e "Unknown version: $2" && return 1
    
    if [[ $PATH == *$PVM_DIR/phps/*/bin* ]]
    then
      PATH=${PATH%$PVM_DIR/phps/*/bin*}${PATH#*$PVM_DIR/phps/*/bin:}
    fi
    
    PATH="$PVM_DIR/phps/$VERSION/bin:$PATH"
    
    pvm __export_pvm_version $VERSION
    export PATH=$PATH
    
    ;;
    
  "exec" )
    [ $# -lt 2 ] && pvm help && return 1

    ;;

  "i" | "install" )
    [ $# -lt 2 ] && pvm help && return 1
    [ $# -ge 3 ] && ALIAS=$3

    [ ! -d "$PVM_DIR" ] && pvm __export_pvm_dir
    [ ! -d "$PVM_DIR" ] && return 1
    
    VERSION=`pvm __parse_version $2`
    SRC_URL=`pvm __download_src_url $VERSION`
    SRC="$PVM_DIR/build/php-$VERSION"
    TAR="$PVM_DIR/tars/php-$VERSION.tar.gz"
    LOG="$PVM_DIR/build/php-$VERSION.log"

    PREFIX="$PVM_DIR/phps/$VERSION"
    [ "$ALIAS" != "" ] && PREFIX="$PREFIX-$ALIAS"

    shift ; shift ; shift

    rm -rf   $SRC
    mkdir -p "$PVM_DIR/build"
    mkdir -p "$PVM_DIR/tars"
    
    cd       "$PVM_DIR/build"
    touch    $LOG

    if [ ! -f $TAR ]
    then
      pvm __l "Fetching $VERSION ..."
      pvm __fetch -o $TAR --progress-bar $SRC_URL || return 1
    fi

    pvm __l "Unpacking $VERSION-$ALIAS ..."
    tar -xzf $TAR || return 1

    cd $SRC

    pvm __l "Configuring $VERSION-$ALIAS ..."
    ./configure --prefix $PREFIX $@ 1>>$LOG 2>>$LOG || return 1

    # fix dSYM bug
    sed 's/^EXEEXT = \.dSYM/EXEEXT = /' Makefile > Makefile.new
    cp Makefile.new Makefile
    rm Makefile.new

    pvm __l "Building $VERSION-$ALIAS ... (this may take a while)"
    make 1>>$LOG 2>>$LOG || return 1
    rm -rf $PREFIX
    pvm __l "Installing to: $PREFIX"
    make install 2>&1 >> $LOG || return 1

    ;;

  "setup" )
    [ $# -ne 1 ] && return 1
    mkdir -p "$HOME/.pvm"
    ;;

  "__parse_version" )
    [ $# -gt 2 ] && return 1

    VERSION=$2

    [ "$VERSION" == "" ] && VERSION="$PVM_VERSION"
    [ "$VERSION" == "" ] && [ -f "$PVM_DIR/default" ] && VERSION=`cat $PVM_DIR/default`
    [ "$VERSION" == "" ] && return 1

    echo $VERSION

    ;;
    
  "__export_pvm_version" )
    [ $# -gt 2 ] && return 1
    
    export PVM_VERSION=$(pvm __parse_version)
    [ "$PVM_VERSION" == "" ] && return 1
    
    return 0
    
    ;;

  "__export_pvm_dir" )
    [ $# -ne 1 ] && return 1

    [ "$PVM_DIR" != "" ]    && [ -d "$PVM_DIR" ]               && return 0
    [ -d "$HOME/.pvm" ]     && export PVM_DIR="$HOME/.pvm"     && return 0
    [ -d "/usr/local/pvm" ] && export PVM_DIR="/usr/local/pvm" && return 0
    pvm __e "No pvm installation was found!" && return 1
    ;;

  "__download_src_url" )
    [ $# -ne 2 ] && return 1

    case $2 in
    "5.3.7"  ) echo "http://www.php.net/get/php-$2.tar.gz/from/a/mirror" ;;
    "5.3.6"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.5"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.4"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.3"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.2"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.1"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.3.0"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.16" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.15" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.14" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.13" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.12" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.11" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.10" ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.9"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.8"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.6"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.5"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.4"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.3"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.2"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.1"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    "5.2.0"  ) echo "http://museum.php.net/php5/php-$2.tar.gz" ;;
    esac

    ;;

  "__fetch" )
    if [ `which curl` ]; then
      ARGS="$* "
      ARGS=${ARGS/__fetch /}

      curl $ARGS
    else
      if [ `which wget` ]; then
        ARGS="$* "
        ARGS=${ARGS/__fetch /}
        ARGS=${ARGS/-s /-q }
        ARGS=${ARGS/--progress-bar /}
        ARGS=${ARGS/-C - /-c }
        ARGS=${ARGS/-o /-O }

        wget $ARGS
      else
        pvm __e 'Need curl or wget to proceed.'
        return 1
      fi
    fi
    ;;

  "__e" )
    red=$'\e[1;31m'
    clear=$'\e[0m'
    shift
    echo "$red$@$clear" 1>&2
    ;;

  "__l" )
    yellow=$'\e[1;33m'
    clear=$'\e[0m'
    shift
    echo "$yellow$@$clear"
    ;;

  "__s" )
    green=$'\e[1;32m'
    clear=$'\e[0m'
    shift
    echo "$green$@$clear"
    ;;

  * )
    pvm help && return 1
    ;;

  esac
}
