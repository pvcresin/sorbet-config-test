# sorbet-config-test

Sorbetのruntimeでの型チェック抑制方法まとめ
- https://zenn.dev/pvcresin/articles/cf21841533a878

`bundle install`
`bundle exec tapioca init`

```console
$ ruby lib/sample.rb

--- inline_type_error_handler ---
T.let: Expected type Integer, got type String with value "string"
Caller: lib/sample.rb:44

--- call_validation_error_handler ---
Return value: Expected type String, got type Integer with value 1
Caller: lib/sample.rb:68
Definition: lib/sample.rb:50 (Sample#b)

--- sig_builder_error_handler ---
You must provide a return type; use the `.returns` or `.void` builder methods.

--- sig_validation_error_handler ---
You marked `d` as .override, but that method doesn't already exist in this class/module to be overridden.
  Either check for typos and for missing includes or super classes to make the parent method shows up
  ... or remove .override here: Sample at lib/sample.rb:62
```

`bundle exec srb tc`
