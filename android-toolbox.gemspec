# ------------------------------------------------------------------------------
# The Android Toolbox Gemspec
# ------------------------------------------------------------------------------

Gem::Specification.new do |s|
  s.name        = "android-toolbox"
  s.version     = "0.0.1"
  s.summary     = "The Android developer toolbox"
  s.description = <<EOF
Contains scripts useful when working on Android projects such as scripts
to create nine-patches from SVGs, check translation statistics and so on.
EOF
  s.authors     = ["Lorenzo Villani"]
  s.email       = "lorenzo@villani.me"
  s.files       = ["bin/normalize-id.rb", "bin/scalable-nine-patch.rb"]
  s.homepage    = "https://bitbucket.org/lvillani/android-toolbox/"

  s.add_runtime_dependency("RMagick", ">= 2.11.1")
  s.add_runtime_dependency("nokogiri", ">= 1.4.0")
end
