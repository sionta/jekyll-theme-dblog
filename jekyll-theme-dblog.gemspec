# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'jekyll-theme-dblog'
  spec.version       = '1.0.0'
  spec.authors       = ['Andre Attamimi']
  spec.email         = ['rumatua0@gmail.com']
  spec.summary       = 'Just read, write, and share your story.'
  spec.homepage      = 'https://github.com/sionta/jekyll-theme-dblog'
  spec.license       = 'MIT'

  spec.metadata['plugin_type'] = 'theme'

  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.match(%r{^(assets|_(data|includes|layouts|sass)/|(LICENSE|README|CHANGELOG)((\.(txt|md|markdown)|$)))}i)
  end

  spec.required_ruby_version = '~> 3.1' # 3.2.4-1

  spec.add_runtime_dependency 'jekyll', '~> 4.3'
  spec.add_runtime_dependency 'jekyll-feed', '~> 0.17'
  spec.add_runtime_dependency 'jekyll-gist', '~> 1.5'
  spec.add_runtime_dependency 'jekyll-include-cache', '~> 0.2'
  spec.add_runtime_dependency 'jekyll-paginate', '~> 1.1'
  spec.add_runtime_dependency 'jekyll-redirect-from', '~> 0.16'
  spec.add_runtime_dependency 'jekyll-seo-tag', '~> 2.8'
  spec.add_runtime_dependency 'jekyll-sitemap', '~> 1.4'
  spec.add_runtime_dependency 'jemoji', '~> 0.13'
  # spec.add_development_dependency 'jekyll-admin', '~> 0.11'
end