Usage:
xan [options] <command> [<args>...]
xan [options]

Options:
-h, --help Display this message
<command> -h Display the command help message
--version Print version info and exit

Common options:
-n, --no-headers Typically used to indicate that input file has no headers.
-d, --delimiter <arg> Typically used to indicate a custom delimiter.

    help        Get help regarding the expression language
    --version   Print the tool's version

## Explore & visualize

    count       Count rows in file
    headers (h) Show header names
    view    (v) Preview a CSV file in a human-friendly way
    flatten (f) Display a flattened version of each row of a file
    hist        Print a histogram with rows of CSV file as bars
    plot        Draw a scatter plot or line chart
    heatmap     Draw a heatmap of a CSV matrix
    progress    Display a progress bar while reading CSV data

## Search & filter

    search      Search for (or replace) patterns in CSV data
    grep        Coarse but fast filtering of CSV data
    filter      Only keep some CSV rows based on an evaluated expression
    head        First rows of CSV file
    tail        Last rows of CSV file
    slice       Slice rows of CSV file
    top         Find top rows of a CSV file according to some column
    sample      Randomly sample CSV data

## Sort & deduplicate

    sort        Sort CSV data
    dedup       Deduplicate a CSV file
    shuffle     Shuffle CSV data

## Aggregate

    frequency (freq) Show frequency tables
    groupby          Aggregate data by groups of a CSV file
    stats            Compute basic statistics
    agg              Aggregate data from CSV file
    bins             Dispatch numeric columns into bins
    window           Compute window aggregations (cumsum, rolling mean, lag etc.)

## Combine multiple CSV files

    cat         Concatenate by row or column
    join        Join CSV files
    fuzzy-join  Join a CSV file with another containing patterns (e.g. regexes)
    merge       Merge multiple similar already sorted CSV files

## Add, transform, drop and move columns

    select      Select columns from a CSV file
    drop        Drop columns from a CSV file
    map         Create a new column by evaluating an expression on each CSV row
    transform   Transform a column by evaluating an expression on each CSV row
    enum        Enumerate CSV file by preprending an index column
    flatmap     Emit one row per value yielded by an expression evaluated for each CSV row
    fill        Fill empty cells
    blank       Blank down contiguous identical cell values
    separate    Split a single column into multiple ones

## Format, convert & recombobulate

    behead        Drop header from CSV file
    rename        Rename columns of a CSV file
    input         Read unusually formatted CSV data
    fixlengths    Makes all rows have same length
    fmt           Format CSV output (change field delimiter)
    explode       Explode rows based on some column separator
    implode       Collapse consecutive identical rows based on a diverging column
    from          Convert a variety of formats to CSV
    to            Convert a CSV file to a variety of data formats
    scrape        Scrape HTML into CSV data
    reverse       Reverse rows of CSV data

## Transpose & pivot

    transpose (t)            Transpose CSV file
    pivot     (pivot-wider)  Split distinct values of a column into their own columns
    unpivot   (pivot-longer) Stack multiple columns into fewer columns

## Split a CSV file into multiple

    split       Split CSV data into chunks
    partition   Partition CSV data based on a column value

## Parallelization

    parallel (p) Map-reduce-like parallel computation

## Generate CSV files

    range       Create a CSV file from a numerical range

## Lexicometry & fuzzy matching

    tokenize    Tokenize a text column
    vocab       Build a vocabulary over tokenized documents
    cluster     Cluster CSV data to find near-duplicates

## Matrix & network-related commands

    matrix      Convert CSV data to matrix data
    network     Convert CSV data to network data

## Debug

    eval  Evaluate/debug a single expression
