def fail($message): error($message);
def object($value; $name): if ($value | type) == "object" then $value else fail($name + " must be an object") end;
def boolean($value; $name): if ($value | type) == "boolean" then $value else fail($name + " must be a boolean") end;
def strings($value; $name):
  if ($value | type) != "array" or any($value[]?; type != "string" or contains("\u0000"))
  then fail($name + " must be an array of NUL-free strings") else $value end;
def unknown($object; $allowed; $name):
  (($object | keys) - $allowed) as $keys
  | if ($keys | length) == 0 then $object else fail($name + " contains unknown fields: " + ($keys | join(", "))) end;

. as $input
| object($input.config; "configuration") as $config
| unknown($config; ["all_targets", "default_features", "extra_clippy_args", "packages", "target", "version"]; "configuration")
| if ($config.version // 1) == 1 then . else fail("configuration version must be 1") end
| if (($config.target // $input.host) | type) == "string" and (($config.target // $input.host) | contains("\u0000") | not)
  then . else fail("target must be a NUL-free string") end
| boolean($config.default_features // false; "default_features") as $default_features
| boolean($config.all_targets // true; "all_targets") as $all_targets
| strings($config.extra_clippy_args // []; "extra_clippy_args") as $extra
| object($config.packages // {}; "packages") as $configured
| ($input.metadata.packages | map(select(.id as $id | $input.metadata.workspace_members | index($id))) | sort_by(.name)) as $workspace
| ($workspace | map(.name)) as $names
| (($configured | keys) - $names) as $unknown_packages
| if ($unknown_packages | length) > 0 then fail("unknown packages: " + ($unknown_packages | join(", "))) else . end
| [
    $workspace[]
    | . as $package
    | ($configured[$package.name] // {}) as $override
    | unknown($override; ["all_targets", "default_features", "enabled", "features"]; "package " + $package.name)
    | boolean($override.enabled // true; "package enabled") as $enabled
    | boolean($override.default_features // $default_features; "package default_features") as $package_defaults
    | boolean($override.all_targets // $all_targets; "package all_targets") as $package_targets
    | strings($override.features // []; "package features") as $features
    | (($features - ($package.features | keys)) | unique) as $unknown_features
    | if ($unknown_features | length) > 0 then fail("unknown features for " + $package.name + ": " + ($unknown_features | join(", "))) else . end
    | {
        key: $package.name,
        name: $package.name,
        package_id: ($package.name + "@" + $package.version),
        target_identities: ($package.targets | map({kind: (.kind | sort), name}) | sort_by(.name, .kind)),
        enabled: $enabled,
        default_features: $package_defaults,
        all_targets: $package_targets,
        features: ($features | sort | unique)
      }
  ] as $packages
| {
    version: 1,
    target: ($config.target // $input.host),
    default_features: $default_features,
    all_targets: $all_targets,
    extra_clippy_args: $extra,
    packages: $packages
  }
