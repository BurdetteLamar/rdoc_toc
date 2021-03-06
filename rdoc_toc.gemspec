require_relative 'lib/rdoc_toc/version'

Gem::Specification.new do |spec|
  spec.name          = 'rdoc_toc'
  spec.version       = RDocToc::VERSION
  spec.authors       = ['BurdetteLamar']
  spec.email         = ['burdettelamar@yahoo.com']

  spec.summary       = %q{Build TOC for RDoc.}
  spec.description   = %q{Build Table of Contents (TOC) for Ruby RDoc.}
  spec.homepage      = 'https://github.com/BurdetteLamar/rdoc_toc'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['allowed_push_host'] = 'https:/rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/BurdetteLamar/rdoc_toc'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['rdoc_toc', '_make_toc_file']
  spec.require_paths = ['lib']
end
