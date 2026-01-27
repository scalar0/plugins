# Available functions & operators

## Summary

- [Operators](#operators)
    - [Unary operators](#unary-operators)
    - [Numerical comparison](#numerical-comparison)
    - [String/sequence comparison](#stringsequence-comparison)
    - [Arithmetic operators](#arithmetic-operators)
    - [String/sequence operators](#stringsequence-operators)
    - [Logical operators](#logical-operators)
    - [Indexing & slicing operators](#indexing--slicing-operators)
    - [Pipeline operator](#pipeline-operator)
- [Boolean operations & branching](#boolean-operations--branching)
- [Comparison](#comparison)
- [Arithmetics](#arithmetics)
- [Formatting](#formatting)
- [Strings](#strings)
- [Strings, lists and maps](#strings-lists-and-maps)
- [Lists](#lists)
- [Maps](#maps)
- [Dates & time](#dates--time)
- [Urls & web-related](#urls--webrelated)
- [Fuzzy matching & information retrieval](#fuzzy-matching--information-retrieval)
- [Utils](#utils)
- [IO & path wrangling](#io--path-wrangling)
- [Randomness & hashing](#randomness--hashing)

## Operators

### Unary operators

```txt
!x - boolean negation
-x - numerical negation
```

### Numerical comparison

Warning: those operators will always consider operands as numbers or dates and will try to cast them around as such. For string/sequence comparison, use the operators in the next section.

```txt
x == y - numerical equality
x != y - numerical inequality
x < y  - numerical less than
x <= y - numerical less than or equal
x > y  - numerical greater than
x >= y - numerical greater than or equal
```

### String/sequence comparison

Warning: those operators will always consider operands as strings or sequences and will try to cast them around as such. For numerical comparison, use the operators in the previous section.

```txt
x eq y - string equality
x ne y - string inequality
x lt y - string less than
x le y - string less than or equal
x gt y - string greater than
x ge y - string greater than or equal
```

### Arithmetic operators

```txt
x + y  - numerical addition
x - y  - numerical subtraction
x * y  - numerical multiplication
x / y  - numerical division
x % y  - numerical remainder
x // y - numerical integer division
x ** y - numerical exponentiation
```

### String/sequence operators

```txt
x ++ y - string concatenation
```

### Logical operators

```txt
x && y     - logical and
x and y
x || y     - logical or
x or y
x in y
x not in y
```

### Indexing & slicing operators

Negative indices are accepted and mean the same thing as with the Python language.

```txt
x[y]         - get y from x (string or list index, map key)
x[start:end] - slice x from start index to end index
x[:end]      - slice x from start to end index
x[start:]    - slice x from start index to end
```

### Pipeline operator

using "\_" for left-hand side substitution.

```txt
trim(name) | len(_)         - Same as len(trim(name))
trim(name) | len            - Supports elision for unary functions
trim(name) | add(1, len(_)) - Can be nested
add(trim(name) | len, 2)    - Can be used anywhere
```

## Boolean operations & branching

- **and**(_a_, _b_, _\*n_) -> `T`: Perform boolean AND operation on two or more values.
- **if**(_cond_, _then_, _else?_) -> `T`: Evaluate condition and switch to correct branch.
- **unless**(_cond_, _then_, _else?_) -> `T`: Shorthand for `if(not(cond), then, else?)`
- **not**(_a_) -> `bool`: Perform boolean NOT operation.
- **or**(_a_, _b_, _\*n_) -> `T`: Perform boolean OR operation on two or more values.
- **try**(_T_) -> `T`: Attempt to evaluate given expression and return null if it raised an error.

## Comparison

- **eq**(_s1_, _s2_) -> `bool`: Test string or list equality.
- **ne**(_s1_, _s2_) -> `bool`: Test string or list inequality.
- **gt**(_s1_, _s2_) -> `bool`: Test string or list s1 > s2.
- **ge**(_s1_, _s2_) -> `bool`: Test string or list s1 >= s2.
- **lt**(_s1_, _s2_) -> `bool`: Test string or list s1 < s2.
- **le**(_s1_, _s2_) -> `bool`: Test string or list s1 <= s2.

## Arithmetics

- **abs**(_x_) -> `number`: Return absolute value of number.
- **add**(_x_, _y_, _\*n_) -> `number`: Add two or more numbers.
- **argmax**(_numbers_, _labels?_) -> `any`: Return the index or label of the largest number in the list.
- **argmin**(_numbers_, _labels?_) -> `any`: Return the index or label of the smallest number in the list.
- **ceil**(_x_) -> `number`: Return the smallest integer greater than or equal to x.
- **div**(_x_, _y_, _\*n_) -> `number`: Divide two or more numbers.
- **idiv**(_x_, _y_) -> `number`: Integer division of two numbers.
- **int**(_any_) -> `int`: Cast value as int and raise an error if impossible.
- **float**(_any_) -> `float`: Cast value as float and raise an error if impossible.
- **floor**(_x_) -> `number`: Return the smallest integer lower than or equal to x.
- **log**(_x_, _base?_) -> `number`: Return the natural or custom base logarithm of x.
- **log2**(_x_) -> `number`: Return the base 2 logarithm of x.
- **log10**(_x_) -> `number`: Return the base 10 logarithm of x.
- **max**(_x_, _y_, _\*n_) -> `number`: Return the maximum number.
- **max**(_list_of_numbers_) -> `number`: Return the maximum number.
- **min**(_x_, _y_, _\*n_) -> `number`: Return the minimum number.
- **min**(_list_of_numbers_) -> `number`: Return the minimum number.
- **mod**(_x_, _y_) -> `number`: Return the remainder of x divided by y.
- **mul**(_x_, _y_, _\*n_) -> `number`: Multiply two or more numbers.
- **neg**(_x_) -> `number`: Return -x.
- **pow**(_x_, _y_) -> `number`: Raise x to the power of y.
- **round**(_x_) -> `number`: Return x rounded to the nearest integer.
- **sqrt**(_x_) -> `number`: Return the square root of x.
- **sub**(_x_, _y_, _\*n_) -> `number`: Subtract two or more numbers.
- **trunc**(_x_) -> `number`: Truncate the number by removing its decimal part.

## Formatting

- **bytesize**(_string_) -> `string`: Return a number of bytes in human-readable format (KB, MB, GB, etc.).
- **escape_regex**(_string_) -> `string`: Escape a string so it can be used safely in a regular expression.
- **fmt**(_string_, _\*arguments_) -> `string`: Format a string by replacing "{}" occurrences by subsequent arguments.<br>Example: `fmt("Hello {} {}", name, surname)` will replace the first "{}" by the value of the name column, then the second one by the value of the surname column.<br>Can also be given a substitution map like so:<br>`fmt("Hello {name}", {name: "John"})`.
- **fmt**(_string_, _map_) -> `string`: Format a string by replacing "{}" occurrences by subsequent arguments.<br>Example: `fmt("Hello {} {}", name, surname)` will replace the first "{}" by the value of the name column, then the second one by the value of the surname column.<br>Can also be given a substitution map like so:<br>`fmt("Hello {name}", {name: "John"})`.
- **lower**(_string_) -> `string`: Lowercase string.
- **pad**(_string_, _width_, _char?_) -> `string`: Pad given string with spaces or given character so that it is least given width.
- **lpad**(_string_, _width_, _char?_) -> `string`: Left pad given string with spaces or given character so that it is least given width.
- **rpad**(_string_, _width_, _char?_) -> `string`: Right pad given string with spaces or given character so that it is least given width.
- **printf**(_format_, _\*arguments_) -> `string`: Apply printf formatting with given format and arguments. Arguments can also be provided as a list.<br>For instance: `split('John Landy') | printf('first: %s, last: %s', _)`
- **numfmt**(_number_, _thousands_sep=","_, _comma=false_, _significance=5_) -> `string`: Format a number with thousands separator and proper significance.
- **trim**(_string_, _chars?_) -> `string`: Trim string of leading & trailing whitespace or provided characters.
- **to_fixed**(_number_, _precision_) -> `string`: Format given number using fixed point notation with specified number of decimal places.
- **ltrim**(_string_, _chars?_) -> `string`: Trim string of leading whitespace or provided characters.
- **rtrim**(_string_, _chars?_) -> `string`: Trim string of trailing whitespace or provided characters.
- **upper**(_string_) -> `string`: Uppercase string.

## Strings

- **count**(_string_, _substring_) -> `int`: Count number of times substring appear in string. Or count the number of times a regex pattern matched the strings. Note that only non-overlapping matches will be counted in both cases. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.
- **count**(_string_, _regex_) -> `int`: Count number of times substring appear in string. Or count the number of times a regex pattern matched the strings. Note that only non-overlapping matches will be counted in both cases. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.
- **endswith**(_string_, _substring_) -> `bool`: Test if string ends with substring.
- **match**(_string_, _regex_, _group_) -> `string`: Return a regex pattern match on the string. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.
- **replace**(_string_, _substring_, _replacement_) -> `string`: Replace all non-overlapping occurrences of substring in given string with provided replacement. Can also replace regex pattern matches. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.<br>See regex replacement string syntax documentation here:<br>https://docs.rs/regex/latest/regex/struct.Regex.html#replacement-string-syntax
- **replace**(_string_, _regex_, _replacement_) -> `string`: Replace all non-overlapping occurrences of substring in given string with provided replacement. Can also replace regex pattern matches. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.<br>See regex replacement string syntax documentation here:<br>https://docs.rs/regex/latest/regex/struct.Regex.html#replacement-string-syntax
- **split**(_string_, _substring_, _max?_) -> `list`: Split a string by a given separator substring. Can also split using a regex pattern. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.
- **split**(_string_, _regex_, _max?_) -> `list`: Split a string by a given separator substring. Can also split using a regex pattern. Remember a regex pattern must be written with slashes e.g. `/france|french/i`.
- **startswith**(_string_, _substring_) -> `bool`: Test if string starts with substring.

## Strings, lists and maps

- **concat**(_string_, _\*strings_) -> `string`: Concatenate given strings into a single one.
- **contains**(_string_, _substring_) -> `bool`: If target is a string: return whether substring can be found in it or return whether given regular expression matched.<br>If target is a list, returns whether given item was found in it.<br>If target is a map, returns whether given key was found in it.
- **contains**(_string_, _regex_) -> `bool`: If target is a string: return whether substring can be found in it or return whether given regular expression matched.<br>If target is a list, returns whether given item was found in it.<br>If target is a map, returns whether given key was found in it.
- **contains**(_list_, _item_) -> `bool`: If target is a string: return whether substring can be found in it or return whether given regular expression matched.<br>If target is a list, returns whether given item was found in it.<br>If target is a map, returns whether given key was found in it.
- **contains**(_map_, _key_) -> `bool`: If target is a string: return whether substring can be found in it or return whether given regular expression matched.<br>If target is a list, returns whether given item was found in it.<br>If target is a map, returns whether given key was found in it.
- **first**(_seq_) -> `T`: Get first char of string or first item of list.
- **last**(_seq_) -> `T`: Get last char of string or first item of list.
- **len**(_seq_) -> `int`: Get number of chars in string or number of items in list.
- **get**(_string_, _index_, _default?_) -> `any`: If target is a string, return the nth unicode char. If target is a list, return the nth item. Indices are zero-based and can be negative to access items in reverse. If target is a map, return the value associated with given key. All variants can also take a default value when desired item is not found.
- **get**(_list_, _index_, _default?_) -> `any`: If target is a string, return the nth unicode char. If target is a list, return the nth item. Indices are zero-based and can be negative to access items in reverse. If target is a map, return the value associated with given key. All variants can also take a default value when desired item is not found.
- **get**(_map_, _key_, _default?_) -> `any`: If target is a string, return the nth unicode char. If target is a list, return the nth item. Indices are zero-based and can be negative to access items in reverse. If target is a map, return the value associated with given key. All variants can also take a default value when desired item is not found.
- **slice**(_seq_, _start_, _end?_) -> `seq`: Return slice of string or list.

## Lists

- **all**(_list_, _lambda_) -> `bool`: Returns whether the given lambda returned true for all elements of the list.<br>For instance: `all(names, name.startswith('A'))`
- **any**(_list_, _lambda_) -> `bool`: Returns whether the given lambda returned true for any element of the list.<br>For instance: `any(names, name.startswith('A'))`
- **compact**(_list_) -> `list`: Drop all falsey values from given list.
- **filter**(_list_, _lambda_) -> `list`: Return a list containing only elements for which given lambda returned true.<br>For instance: `filter(names, name => name.startswith('A'))`
- **find**(_list_, _lambda_) -> `any?`: Return the first item of a list for which given lambda returned true.<br>For instance: `find(names, name => name.startswith('A'))`
- **find_index**(_list_, _lambda_) -> `int?`: Return the index of the first item of a list for which given lambda returned true.<br>For instance: `find_index(names, name => name.startswith('A'))`
- **index_by**(_list_, _key_) -> `map`: Take a list of maps and a key name and return an indexed map from selected keys to the original maps.
- **join**(_list_, _sep_) -> `string`: Join list by separator.
- **map**(_list_, _lambda_) -> `list`: Return a list with elements transformed by given lambda.<br>For instance: `map(numbers, n => n + 3)`
- **mean**(_numbers_) -> `number?`: Return the mean of the given numbers.
- **sum**(_numbers_) -> `number?`: Return the sum of the given numbers, or nothing if the sum overflowed.

## Maps

- **keys**(_map_) -> `[string]`: Return a list of the map's keys.
- **values**(_map_) -> `[T]`: Return a list of the map's values.

## Dates & time

- **datetime**(_string_, _format=?_, _timezone=?_) -> `datetime`: Parse a string as a datetime according to format and timezone. If no format is provided, string is parsed as ISO 8601 date format. Default timezone is the system timezone.<br>https://docs.rs/jiff/latest/jiff/fmt/strtime/index.html#conversion-specifications
- **earliest**(_datetime1_, _datetime2_, _\*datetimen_) -> `datetime`: Return the earliest datetime.
- **earliest**(_list_of_datetimes_) -> `datetime`: Return the earliest datetime.
- **latest**(_datetime1_, _datetime2_, _\*datetimen_) -> `datetime`: Return the latest datetime.
- **latest**(_list_of_datetimes_) -> `datetime`: Return the latest datetime.
- **strftime**(_target_, _format_) -> `string`: Format target (a time in ISO 8601 format, or the result of datetime() function) according to format.
- **timestamp**(_number_) -> `datetime`: Parse a number as a POSIX timestamp in seconds (nb of seconds since 1970-01-01 00:00:00 UTC), and convert it to a datetime in local time.
- **timestamp_ms**(_number_) -> `datetime`: Parse a number as a POSIX timestamp in milliseconds (nb of milliseconds since 1970-01-01 00:00:00 UTC), and convert it to a datetime in local time.
- **to_timezone**(_target_, _timezone_in_, _timezone_out_) -> `datetime`: Parse target (a time in ISO 8601 format, or the result of datetime() function) in timezone_in, and convert it to timezone_out.
- **to_local_timezone**(_target_) -> `datetime`: Parse target (a time in ISO 8601 format, or the result of datetime() function) in timezone_in, and convert it to the system's local timezone.
- **year_month_day**(_target_) -> `string` (aliases: **ymd**): Extract the year, month and day of a datetime. If the input is a string, first parse it into datetime, and then extract the year, month and day.<br>Equivalent to `strftime(string, format="%Y-%m-%d")`.
- **month_day**(_target_) -> `string`: Extract the month and day of a datetime. If the input is a string, first parse it into datetime, and then extract the month and day.<br>Equivalent to `strftime(string, format="%m-%d")`.
- **month**(_target_) -> `string`: Extract the month of a datetime. If the input is a string, first parse it into datetime, and then extract the month.<br>Equivalent to `strftime(string, format="%m")`.
- **year**(_target_) -> `string`: Extract the year of a datetime. If the input is a string, first parse it into datetime, and then extract the year.<br>Equivalent to `strftime(string, format="%Y")`.
- **year_month**(_target_) -> `string` (aliases: **ym**): Extract the year and month of a datetime. If the input is a string, first parse it into datetime, and then extract the year and month.<br>Equivalent to `strftime(string, format="%Y-%m")`.

## Urls & web-related

- **html_unescape**(_string_) -> `string`: Unescape given HTML string by converting HTML entities back to normal text.
- **lru**(_string_) -> `string`: Convert the given URL to LRU format.<br>For more info, read this: https://github.com/medialab/ural#about-lrus
- **mime_ext**(_string_) -> `string`: Return the extension related to given mime type.
- **parse_dataurl**(_string_) -> `[string, bytes]`: Parse the given data url and return its mime type and decoded binary data.
- **urljoin**(_string_, _string_) -> `string`: Join an url with the given addendum.

## Fuzzy matching & information retrieval

- **fingerprint**(_string_) -> `string`: Fingerprint a string by normalizing characters, re-ordering and deduplicating its word tokens before re-joining them by spaces.
- **carry_stemmer**(_string_) -> `string`: Apply the "Carry" stemmer targeting the French language.
- **s_stemmer**(_string_) -> `string`: Apply a very simple stemmer removing common plural inflexions in some languages.
- **unidecode**(_string_) -> `string`: Convert string to ascii as well as possible.

## Utils

- **col**(_name_or_pos_, _nth?_) -> `bytes`: Return value of cell for given column, by name, by position or by name & nth, in case of duplicate header names.
- **col?**(_name_or_pos_, _nth?_) -> `bytes`: Return value of cell for given column, by name, by position or by name & nth, in case of duplicate header names. Allow selecting inexisting columns, in which case it will return null.
- **header**(_name_or_pos_, _nth?_) -> `bytes`: Return header name for given column, by name, by position or by name & nth, in case of duplicate header names.
- **header?**(_name_or_pos_, _nth?_) -> `bytes`: Return header namefor given column, by name, by position or by name & nth, in case of duplicate header names. Allow selecting inexisting columns, in which case it will return null.
- **col_index**(_name_or_pos_, _nth?_) -> `bytes`: Return zero-based index of given column, by name, by position or by name & nth, in case of duplicate header names.
- **col_index?**(_name_or_pos_, _nth?_) -> `bytes`: Return zero-based index of given column, by name, by position or by name & nth, in case of duplicate header names. Allow selecting inexisting columns, in which case it will return null.
- **cols**(_from_name_or_pos?_, _to_name_or_pos?_) -> `list[bytes]`: Return list of cell values from the given column by name or position to another given column by name or position, inclusive. Can also be called with a single argument to take a slice from the given column to the end, or no argument at all to take all columns.
- **err**(_msg_) -> `error`: Make the expression return a custom error.
- **headers**(_from_name_or_pos?_, _to_name_or_pos?_) -> `list[string]`: Return list of header names from the given column by name or position to another given column by name or position, inclusive. Can also be called with a single argument to take a slice from the given column to the end, or no argument at all to return all headers.
- **index**() -> `int?`: Return the row's index, if applicable.
- **regex**(_string_) -> `regex`: Parse given string as regex. Useful when your patterns are dynamic, e.g. built from a CSV cell. Else prefer using regex literals e.g. "/test/".
- **typeof**(_value_) -> `string`: Return type of value.

## IO & path wrangling

- **abspath**(_string_) -> `string`: Return absolute & canonicalized path.
- **cmd**(_string_, _list[string]_) -> `bytes`: Run a command using the provided list of arguments as a subprocess and return the resulting bytes trimmed of trailing whitespace.
- **copy**(_source_path_, _target_path_) -> `string`: Copy a source to target path. Will create necessary directories on the way. Returns target path as a convenience.
- **ext**(_path_) -> `string?`: Return the path's extension, if any.
- **filesize**(_string_) -> `int`: Return the size of given file in bytes.
- **isfile**(_string_) -> `bool`: Return whether the given path is an existing file on disk.
- **move**(_source_path_, _target_path_) -> `string`: Move a source to target path. Will create necessary directories on the way. Returns target path as a convenience.
- **parse_json**(_string_) -> `any`: Parse the given string as JSON.
- **pathjoin**(_string_, _\*strings_) -> `string` (aliases: **pjoin**): Join multiple paths correctly.
- **read**(_path_, _encoding="utf-8"_, _errors="strict"_) -> `string`: Read file at path. Default encoding is "utf-8". Default error handling policy is "replace", and can be one of "replace", "ignore" or "strict".
- **read_csv**(_path_) -> `list[map]`: Read and parse CSV file at path, returning its rows as a list of maps with headers as keys.
- **read_json**(_path_) -> `any`: Read and parse JSON file at path.
- **shell**(_string_) -> `bytes`: Convenience function running `cmd("$SHELL -c <command>") ` on unix-like systems and `cmd("cmd \C <command>")` on Windows.
- **shlex_split**(_string_) -> `list[string]`: Split a string of command line arguments into a proper list that can be given to e.g. the `cmd` function.
- **write**(_string_, _path_) -> `string`: Write string to path as utf-8 text. Will create necessary directories recursively before actually writing the file. Return the path that was written.

## Randomness & hashing

- **md5**(_string_) -> `string`: Return the md5 hash of string in hexadecimal representation.
- **random**() -> `float`: Return a random float between 0 and 1.
- **uuid**() -> `string`: Return a uuid v4.
