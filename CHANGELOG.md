# CHANGELOG

## Ver. 0.1.0 (First release!) - 2024-03-14

### Release Highlights

Creation of the foreign currency API. Implementation of two function `getcurrency_list` e `gettimeseries`, the first returns a dataframe of all avaliable currencies in the BCB's data API, and the second returns a time series in a dataframe format of foreign exchange prices between any currencies avaliable.

## Ver. 0.1.1 - 2024-03-25

## Release Highlights

Creation of the Currency type.

## Bug fixes

- Fixed bug where country name would come with trailing white spaces when using `getcurrency_list`.

## Breaking Changes

None.

### Future breaks

In version 0.2.0 the `gettimeseries` function will be renamed to `getcurrencyseries`.

## Ver. 0.2.0 - 2024-04-23

## Release highlights

Creation of the SGS module, giving the API access to the time series database of the Brazilian Central Bank.

## Breaking changes

- `gettimeseries` from the currency module renamed to `getcurrencyseries`
- `getCurrency` from the currency module renamed to `Currency`
