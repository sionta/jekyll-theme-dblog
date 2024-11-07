# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem 'jekyll-archives', '~> 2.2'
  gem 'jekyll-toc', '~> 0.19'
  gem 'kramdown-math-katex'
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem 'tzinfo', '>= 1', '< 3'
  gem 'tzinfo-data'
end

# Performance-booster for watching directories on Windows
gem 'wdm', '>= 0.1.0' if Gem.win_platform?
