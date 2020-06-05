# Webtrekk Analytics Connector

![logo for "daten.berlin.de Usage Statistics" dataset](logo/webtrekk_connector_logo_small.png)

`webtrekk_connector` is a simple Ruby wrapper for the [Webtrekk/Mapp](https://mapp.com/mapp-cloud/mapp-intelligence/) Analytics API (see [https://support.webtrekk.com/hc/de/articles/115001497529-JSON-RPC-API](https://support.webtrekk.com/hc/de/articles/115001497529-JSON-RPC-API)).

## Installation

```
gem install webtrekk_connector
```

## Usage

Basically:

- Instantiate the connector with an endpoint, username and password.
- Login by calling `connector.login` (this will request a token and store it).
- Happily call methods à la `connector.getAnalysisObjectsAndMetricsList`.
- All complex parameters to method wrappers are Ruby Hashes.
- Likewise, complex return values are Hashes (or Arrays).

## Example

### Require the gem

```ruby
$ irb
> require 'webtrekk_connector'
 => true 
```

### Define the Configuration Object

```ruby
> conf = {
>   :endpoint => "https://xyz.endpoint.com/cgi-bin/wt/JSONRPC.cgi" ,
>   :user => "Foobar.baz" ,
>   :pwd => "fancypassword_1234"
> }
```

### Instantiate the Connector

```ruby
> connector = WebtrekkConnector.new(conf)
# I, [2020-05-18T15:37:16.694389 #74806]  INFO -- : Connector set up for https://xyz.endpoint.com/cgi-bin/wt/JSONRPC.cgi.
```

### Call Methods

```ruby
# some methods can be called without logging in:
> connector.get_account_list
# I, [2020-05-18T15:37:45.869833 #74806]  INFO -- : call_method: getAccountList
# I, [2020-05-18T15:37:45.870000 #74806]  INFO -- : sending request (method getAccountList) ...
 => [{"customerId"=>"748395739204857", "title"=>"Account No. 1"}]

# others require to be logged in:
> connector.get_analysis_objects_and_metrics_list
# I, [2020-05-18T15:38:13.095789 #74806]  INFO -- : call_method: getAnalysisObjectsAndMetricsList
# I, [2020-05-18T15:38:13.095897 #74806]  INFO -- : sending request (method getAnalysisObjectsAndMetricsList) ...
 => nil
```

### Login

```ruby
> connector.login
# I, [2020-05-18T15:38:27.902296 #74806]  INFO -- : call_method: getAccountList
# I, [2020-05-18T15:38:27.902396 #74806]  INFO -- : sending request (method getAccountList) ...
# I, [2020-05-18T15:38:31.026991 #74806]  INFO -- : call_method: login
# I, [2020-05-18T15:38:31.027553 #74806]  INFO -- : sending request (method login) ...
 => "37f794e0e96e9285ec75b5ba4513c25f_835daa8caf6263b122d97ec97ad122c7" 

> connector.get_analysis_objects_and_metrics_list
# I, [2020-05-18T15:38:43.190740 #74806]  INFO -- : call_method: getAnalysisObjectsAndMetricsList
# I, [2020-05-18T15:38:43.190908 #74806]  INFO -- : sending request (method getAnalysisObjectsAndMetricsList) ...
 => {"customMetrics"=>[], "metrics"=>["% of All Visitors", "% of All Visits", ... , "Visits with Search Phrase"], "analysisObjects"=>[" Day since Customer Journey Start", "Ad Media Path", ... , "Years"]}
```

## License

All software in this repository is published under the [MIT License](LICENSE).

---

2020, Knud Möller, [BerlinOnline Stadtportal GmbH & Co. KG](https://www.berlinonline.net)

Last changed: 2020-05-18
