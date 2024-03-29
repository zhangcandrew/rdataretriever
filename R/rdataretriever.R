if (!requireNamespace("reticulate", quietly = TRUE)) {
  return()
} else {
  library(reticulate)
}

#' Fetch a dataset via the Data Retriever
#'
#' Each datafile in a given dataset is downloaded to a temporary directory and
#' then imported as a data.frame as a member of a named list.
#'
#' @param dataset the names of the dataset that you wish to download
#' @param quiet logical, if true retriever runs in quiet mode
#' @param data_names the names you wish to assign to cells of the list which
#' stores the fetched dataframes. This is only relevant if you are
#' downloading more than one dataset.
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' ## fetch the portal Database
#' portal = rdataretriever::fetch('portal')
#' class(portal)
#' names(portal)
#' ## preview the data in the portal species datafile
#' head(portal$species)
#' vegdata = rdataretriever::fetch(c('plant-comp-ok', 'plant-occur-oosting'))
#' names(vegdata)
#' names(vegdata$plant_comp_ok)
#' }
fetch = function(dataset, quiet=TRUE, data_names=NULL){
  r_data_retriever = reticulate::import('retriever')
  data_sets = list()
  #Accessing datasets() function from Python API
  for (x in r_data_retriever$datasets()) {
    data_sets = c(data_sets, x$name)
  }

  if (!dataset %in% data_sets) {
    stop(
      "The dataset requested isn't currently available in the rdataretriever.\n
      Run rdataretriever::datasets() to get a list of available datasets\n
      Or run rdataretriever::get_updates() to get the newest available datasets."
    )
  }
  temp_path = tolower(tempdir())
  if (!dir.exists(temp_path)) {
    dir.create(temp_path)
  }
  datasets = vector('list', length(dataset))
  if (is.null(data_names)) {
    names(datasets) = dataset
    names(datasets) = gsub('-', '_', names(datasets))
  }
  else {
    if (length(data_names) != length(dataset)) {
      stop('Number of names must match number of datasets')
    }
    else if ((length(data_names) == 1) & (length(dataset) == 1)) {
      stop("Assign name through the output instead (e.g., yourname = fetch('dataset')")
      names(datasets) = data_names
    }
  }
  for (i in seq_along(dataset)) {
    if (quiet) {
      #Accessing install() function from Python API
      r_data_retriever$install_csv(dataset = dataset[i],
                                   table_name = '{db}_{table}.csv', data_dir=temp_path)
    } else {
      r_data_retriever$install_csv(dataset = dataset[i],
                                   table_name = '{db}_{table}.csv', data_dir=temp_path,
                                   debug = TRUE)
    }
    files = dir(temp_path)
    dataset_underscores = gsub('-', '_', dataset[i])
    files = files[grep(dataset_underscores, files)]
    tempdata = vector('list', length(files))
    list_names = sub('.csv', '', files)
    list_names = sub(paste(dataset_underscores, '_', sep = ''),
                     '', list_names)
    names(tempdata) = list_names
    for (j in seq_along(files)) {
      tempdata[[j]] = utils::read.csv(file.path(temp_path, files[j]))
    }
    datasets[[i]] = tempdata
  }
  if (length(datasets) == 1)
    datasets = datasets[[1]]
  return(datasets)
}

#' Download datasets via the Data Retriever.
#'
#' Directly downloads data files with no processing, allowing downloading of
#' non-tabular data.
#'
#' @param dataset the name of the dataset that you wish to download
#' @param path the path where the data should be downloaded to
#' @param quiet logical, if true retriever runs in quiet mode
#' @param sub_dir if true and the downloaded dataset is stored in subdirectories those subdirectories will be preserved and placed according the path argument, defaults to false.
#' @param debug Setting TRUE helps in debugging in case of errors
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::download('plant-comp-ok')
#' # downloaded files will be copied to your working directory
#' # when no path is specified
#' dir()
#' }
download = function(dataset, path = './', quiet = FALSE, sub_dir = FALSE, debug = FALSE) {
  r_data_retriever = reticulate::import('retriever')
  if (sub_dir)
    r_data_retriever$download(dataset = dataset, path = path)
  else
    r_data_retriever$download(dataset = dataset)
}

#' Name all available dataset scripts.
#'
#' Additional information on the available datasets can be found at url https://retriever.readthedocs.io/en/latest/datasets.html
#'
#' @return returns a character vector with the available datasets for download
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::datasets()
#' }
datasets = function() {
  r_data_retriever =  reticulate::import('retriever')
  data_sets = c()
  #Accessing datasets() function from Python API
  for (x in r_data_retriever$datasets()) {
    data_sets = c(data_sets, x$name)
  }
  print(data_sets)
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in CSV files
#'
#' @param dataset the name of the dataset that you wish to install
#' @param table_name the name of the database file to store data
#' @param data_dir the dir path to store data, defaults to working dir
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_csv('iris')
#' }
install_csv = function(dataset, table_name = '{db}_{table}.csv', data_dir=getwd(), debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  r_data_retriever$install_csv(dataset, table_name , data_dir, debug, use_cache)
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in JSON files
#'
#' @param dataset the name of the dataset that you wish to install
#' @param table_name the name of the database file to store data
#' @param data_dir the dir path to store data, defaults to working dir
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_json('iris')
#' }
install_json = function(dataset, table_name = '{db}_{table}.json', data_dir=getwd(), debug = FALSE, use_cache = TRUE) {
  r_data_retriever = import('retriever')
  r_data_retriever$install_json(dataset, table_name , data_dir, debug, use_cache)
}


#' Install datasets via the Data Retriever.
#'
#' Data is stored in XML files
#'
#' @param dataset the name of the dataset that you wish to install
#' @param table_name the name of the database file to store data
#' @param data_dir the dir path to store data, defaults to working dir
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_xml('iris')
#' }
install_xml = function(dataset, table_name = '{db}_{table}.xml', data_dir=getwd(), debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  r_data_retriever$install_xml(dataset, table_name , data_dir, debug, use_cache)
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in MySQL database
#'
#' @param dataset the name of the dataset that you wish to install
#' @param user username for database connection
#' @param password password for database connection
#' @param host hostname for connection
#' @param port port number for connection
#' @param database_name database name in which dataset will be installed
#' @param table_name table name specified especially for datasets
#' containing one file
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever :: install_mysql(dataset='portal', user='postgres', password='abcdef')
#' }
install_mysql = function(dataset, user = 'root', password = '', host = 'localhost',
                         port = 3306, database_name = '{db}', table_name = '{db}.{table}',
                         debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  r_data_retriever$install_mysql(dataset, user, password, host,
                                 port, database_name, table_name,
                                 debug, use_cache)
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in PostgreSQL database
#'
#' @param dataset the name of the dataset that you wish to install
#' @param user username for database connection
#' @param password password for database connection
#' @param host hostname for connection
#' @param port port number for connection
#' @param database the database name default is postres
#' @param database_name database schema name in which dataset will be installed
#' @param table_name table name specified especially for datasets
#' containing one file
#' @param bbox Optional extent values used to fetch data from the spatial dataset
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_postgres(dataset='portal', user='postgres', password='abcdef')
#' }
install_postgres = function(dataset, user = 'postgres', password = '',
                            host = 'localhost', port = 5432, database = 'postgres',
                            database_name = '{db}', table_name = '{db}.{table}',
                            bbox = list(), debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  #Use the R list function explicitly
  bbox = reticulate::r_to_py(bbox)
  r_data_retriever$install_postgres(dataset, user, password, host,
                                    port, database, database_name,
                                    table_name, bbox, debug, use_cache)
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in SQLite database
#'
#' @param dataset the name of the dataset that you wish to install
#' @param file Sqlite database file name or path
#' @param table_name table name for installing of dataset
#' @param data_dir the dir path to store the db, defaults to working dir
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_sqlite(dataset='iris', file='sqlite.db', debug=FALSE, use_cache=TRUE)
#' }
install_sqlite = function(dataset, file = 'sqlite.db', table_name = '{db}_{table}',
                          data_dir=getwd(), debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  tryCatch(withCallingHandlers(
    {r_data_retriever$install_sqlite(dataset, file, table_name, data_dir, debug, use_cache)},
    error=function(error_message) {
      message("Full error trace:")
      message(error_message)
      return(NA)
    }
    )
    )
}

#' Install datasets via the Data Retriever.
#'
#' Data is stored in MSAccess database
#'
#' @param dataset the name of the dataset that you wish to install
#' @param file file name for database
#' @param table_name table name for installing of dataset
#' @param debug Setting TRUE helps in debugging in case of errors
#' @param use_cache Setting FALSE reinstalls scripts even if they are already installed
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::install_msaccess(dataset='iris', file='sqlite.db',debug=FALSE, use_cache=TRUE)
#' }
install_msaccess = function(dataset, file = 'access.mdb', table_name = '[{db} {table}]',
                            debug = FALSE, use_cache = TRUE) {
  r_data_retriever = reticulate::import('retriever')
  r_data_retriever$install_msaccess(dataset, file, table_name, debug, use_cache)
}

#' Install datasets via the Data Retriever (deprecated).
#'
#' Data is stored in either CSV files or one of the following database management
#' systems: MySQL, PostgreSQL, SQLite, or Microsoft Access.
#'
#' @param dataset the name of the dataset that you wish to download
#' @param connection what type of database connection should be used.
#' The options include: mysql, postgres, sqlite, msaccess, or csv'
#' @param db_file the name of the datbase file the dataset should be loaded
#' into
#' @param conn_file the path to the .conn file that contains the connection
#' configuration options for mysql and postgres databases. This defaults to
#' mysql.conn or postgres.conn respectively. The connection file is a file that
#' is formated in the following way:
#' \tabular{ll}{
#'   host     \tab my_server@my_host.com\cr
#'   port     \tab my_port_number       \cr
#'   user     \tab my_user_name         \cr
#'   password \tab my_password
#' }
#' @param data_dir the location where the dataset should be installed.
#' Only relevant for csv connection types. Defaults to current working directory
#' @param log_dir the location where the retriever log should be stored if
#' the progress is not printed to the console
#' @export
#' @examples
#' \donttest{
#' rdataretriever::install('iris', 'csv')
#' }
install = function(dataset, connection, db_file = NULL, conn_file = NULL,
                   data_dir = '.', log_dir = NULL) {
  # This function is deprecated
  paste("This function it deprecated use, install_",
    connection, "()", sep = "")
  if (connection == 'mysql' | connection == 'postgres') {
    if (is.null(conn_file)) {
      conn_file = paste('./', connection, '.conn', sep = '')
    }
    if (!file.exists(conn_file)) {
      format = '\nhost my_server@myhost.com\nport my_port_number\n
                user my_user_name\npassword my_pass_word'
      stop(
        paste(
          "conn_file:",
          conn_file,
          "does not exist. To use a",
          connection,
          "server create a 'conn_file' with the format:",
          format,
          "\nwhere order of arguments does not matter"
        )
      )
    }
    conn = data.frame(t(utils::read.table(conn_file, row.names = 1)))
    writeLines(strwrap(paste('Using conn_file:', conn_file, 'to connect to a',
        connection, 'server on host:', conn$host)))
    if (connection == 'mysql') {
      install_mysql(dataset, user = conn$user, host = conn$host,
        port = conn$port, password = conn$password)
    }
    if (connection == 'postgres') {
      install_postgres(dataset, user = conn$user, host = conn$host,
        port = conn$port, password = conn$password)
    }
  } else if (connection == 'msaccess') {
    if (is.null(db_file)) {
      install_msaccess(dataset)
    } else{
      install_msaccess( dataset, file = 'access.mdb',
        table_name = '[{db} {table}]', debug = FALSE, use_cache = TRUE)
    }
  } else if (connection == 'sqlite') {
    if (is.null(db_file)) {
      install_sqlite(dataset)
    }
    else {
      install_sqlite( dataset, file = db_file, table_name = '{db}_{table}',
        debug = FALSE, use_cache = TRUE)
    }
  } else if (connection %in% c('csv', 'json', 'xml')) {
    table_name = file.path(data_dir, paste('{db}_{table}', connection, sep = "."))
    if (connection == 'csv') {
      install_csv(dataset, table_name = table_name, debug = FALSE, use_cache = TRUE)
    }
    else if (connection == 'json') {
      install_json(dataset, table_name = table_name, debug = FALSE, use_cache = TRUE)
    }
    else if (connection == 'xml') {
      install_xml(dataset, table_name = table_name, debug = FALSE, use_cache = TRUE)
    }
  }
}

#' Get dataset citation information and a description
#' @param dataset name of the dataset
#' @return returns a string with the citation information
#' @export
#' @import reticulate
#' @examples
#' \donttest{
#' rdataretriever::get_citation('plant-comp-us')
#' }
get_citation = function(dataset) {
  run_cli(paste('retriever citation', dataset))
}

#' Reset the scripts or data(raw_data) directory or both
#'
#' @param scope All resets both  scripst and data directory
reset = function(scope = 'all') {
  os = Sys.info()[['sysname']]
  home_dir = Sys.getenv('HOME')
  print(paste("This will delete", toupper(scope), "cached infomation"))
  choice.name <- readline(prompt = "Do you want to proceed? (y/N)")
  if (tolower(scope) == "all" & tolower(choice.name) == "y") {
    if (file.exists(file.path(home_dir, ".retriever"))) {
      unlink(file.path(home_dir, ".retriever"), recursive = TRUE)
    }
  } else if (tolower(scope) == "scripts" &
             tolower(choice.name) == "y") {
    if (file.exists(file.path(home_dir, ".retriever", "scripts"))) {
      unlink(file.path(home_dir, ".retriever", "scripts"),
             recursive = TRUE)
    }
  } else if (tolower(scope) == "data" &
             tolower(choice.name) == "y") {
    if (file.exists(file.path(home_dir, ".retriever", "raw_data"))) {
      unlink(file.path(home_dir, ".retriever", "raw_data"),
             recursive = TRUE)
    }
  } else if (tolower(scope) == "connections" &
             tolower(choice.name) == "y") {
    if (file.exists(file.path(home_dir, ".retriever", "connections"))) {
      unlink(file.path(home_dir, ".retriever", "connections"),
             recursive = TRUE)
    }
  }
}

#' Update the retriever's dataset scripts to the most recent versions.
#'
#' This function will check if the version of the retriever's scripts in your local
#' directory \file{~/.retriever/scripts/} is up-to-date with the most recent official
#' retriever release. Note it is possible that even more updated scripts exist
#' at the retriever repository \url{https://github.com/weecology/retriever/tree/master/scripts}
#' that have not yet been incorperated into an official release, and you should
#' consider checking that page if you have any concerns.
#' @keywords utilities
#' @export
#' @examples
#' \donttest{
#' rdataretriever::get_updates()
#' }
get_updates = function() {
  writeLines(strwrap('Please wait while the retriever updates its scripts, ...'))
  update_log = run_cli('retriever update')
  writeLines(strwrap(update_log[3]))
}

#' Setting path of retriever
#'
#' @param path location of retriever in the system
#' @export
#' @examples
#' \donttest{
#' rdataretriever::use_RetrieverPath("/home/<system_name>/anaconda2/envs/py27/bin/")
#' }
use_RetrieverPath = function(path) {
  Sys.setenv(PATH = paste(path, ':', Sys.getenv('PATH'), sep = ''))
}

#' @import reticulate
print.update_log = function(x, ...) {
  if (length(x) == 0) {
    cat('No scripts downloaded')
  }
  else {
    #clean up and print the update log output
    object = strsplit(paste(x, collapse = ' ; '), 'Downloading script: ')
    object = sort(sapply(strsplit(object[[1]][-1], ' ; '),
                         function(x)
                           x[[1]][1]))
    object[1] = paste('Downloaded scripts:', object[1])
    cat(object, fill = TRUE, sep = ', ')
  }
}

.onAttach = function(...) {
  packageStartupMessage(
    "\n  Use get_updates() to download the most recent release of download scripts
    New to rdataretriever? Examples at
    https://github.com/ropensci/rdataretriever/
    Use citation(package='rdataretriever') for the package citation
    \nUse suppressPackageStartupMessages() to suppress these messages in the future"
  )
}

.onLoad = function(...) {
  # Check if retriever can be imported
  check_retriever_import()
}

set_home = function(...) {
  current_home = normalizePath(Sys.getenv('HOME'), winslash = "/")
  Sys.setenv(HOME = gsub("/Documents", "", ignore.case = TRUE, Sys.getenv('HOME')))
}

check_retriever_import = function(){
  # Check if reticulate can import retriever
  tryCatch(
    {imported_retriever = reticulate::import('retriever')},
    error=function(error_message) {
      message("The python module retriever was not found")
      message("Full error trace:")
      message(error_message)
      return(NA)
    }
  )
}

check_for_retriever = function(...) {
  # Detect the Python and retriever paths
  # Export the values as PATH and PYTHONHOME
  python_paths_found = py_config()[13][[1]]
  unique_python_paths = unique(unlist(lapply(python_paths_found, dirname)))
  normalized_python_paths = unlist(lapply(unique_python_paths, normalizePath))
  compile_path = paste(normalized_python_paths, collapse = ':')
  # Export the detected values as part of PATH
  Sys.setenv(PATH = paste(compile_path, ':', Sys.getenv('PATH'), sep = ''))
  # Add these values as part of the PYTHONHOME VALUES
  Sys.setenv(PYTHONPATH = paste(compile_path, ':', Sys.getenv('PATH'), sep =
                                  ''))
  retriever_path = Sys.which('retriever')
  if (retriever_path == '') {
    path_warn = 'The retriever is not on your path and may not be installed.'
    mac_instr = paste(
      'Follow the instructions for installing and manually adding',
      'the Data Retriever to your path at http://www.data-retriever.org/#install',
      sep = ' '
    )
    download_instr = paste(
      'Please upgrade to the most recent version of the Data Retriever which will',
      'automatically add itself to the path http://www.data-retriever.org/#install',
      sep = ' '
    )
    os = Sys.info()[['sysname']]
    if (os == 'Darwin')
      packageStartupMessage(paste(path_warn, mac_instr))
    else
      packageStartupMessage(paste(path_warn, download_instr))
  }
}

run_cli = function(...) {
  os = Sys.info()[['sysname']]
  if (os == "Windows") {
    shell(...)
  } else {
    system(...)
  }
}

get_os <- function() {
  sysinf <- Sys.info()
  if (!is.null(sysinf)) {
    os <- sysinf['sysname']
    if (os == 'Darwin')
      os <- "osx"
  } else {
    ## mystery machine
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os))
      os <- "osx"
    if (grepl("linux-gnu", R.version$os))
      os <- "linux"
  }
  tolower(os)
}
