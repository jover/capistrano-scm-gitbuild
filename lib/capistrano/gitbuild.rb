load File.expand_path('../tasks/gitbuild.rake', __FILE__)

require "capistrano/scm"
require "capistrano/gitbuild/version"

set_if_empty :repo_path, -> { "#{fetch(:tmp_dir)}/#{fetch(:application)}-repo" }

class Capistrano::GitBuild < Capistrano::SCM

  # execute git with argument in the context
  #
  def git(*args)
    args.unshift :git
    context.execute(*args)
  end

  module DefaultStrategy
    def test
      test! " [ -f #{repo_path}/HEAD ] "
    end

    def check
      git :'ls-remote --heads', repo_url
    end

    def clone
      if (depth = fetch(:git_shallow_clone))
        git :clone, '--mirror', '--depth', depth, '--no-single-branch', repo_url, repo_path
      else
        git :clone, '--mirror', repo_url, repo_path
      end
    end

    def update
      # Note: Requires git version 1.9 or greater
      if (depth = fetch(:git_shallow_clone))
        git :fetch, '--depth', depth, 'origin', fetch(:branch)
      else
        git :remote, :update
      end
    end

    def local_build_path
      "#{fetch(:repo_path)}"
    end

    def local_tarfile
      "#{fetch(:tmp_dir)}/#{fetch(:application)}-#{fetch(:current_revision).strip}.tar.gz"
    end

    def remote_tarfile
      "#{fetch(:tmp_dir)}/#{fetch(:application)}-#{fetch(:current_revision).strip}.tar.gz"
    end

    def release
      if (tree = fetch(:repo_tree))
        tree = tree.slice %r#^/?(.*?)/?$#, 1
        components = tree.split('/').size
        git :archive, fetch(:branch), tree, "| tar -x --strip-components #{components} -f - -C", local_build_path
      else
        git :archive, fetch(:branch), '| tar -x -f - -C', local_build_path
      end
    end

    def fetch_revision
      context.capture(:git, "rev-list --max-count=1 --abbrev-commit --abbrev=12 #{fetch(:branch)}")
    end
  end
end
