namespace :gitbuild do

  def strategy
    @strategy ||= Capistrano::GitBuild.new(self, fetch(:git_strategy, Capistrano::GitBuild::DefaultStrategy))
  end

  set :git_environmental_variables, ->() {
    {
      git_askpass: "/bin/echo",
      git_ssh:     "#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh"
    }
  }

  desc 'Upload the git wrapper script, this script guarantees that we can script git without getting an interactive prompt'
  task :wrapper do
    run_locally do
      execute :mkdir, "-p", "#{fetch(:tmp_dir)}/#{fetch(:application)}/"
      File.open("#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh", "w") do |file|
        file.write ("#!/bin/sh -e\nexec /usr/bin/ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \"$@\"\n")
      end
      execute :chmod, "+rx", "#{fetch(:tmp_dir)}/#{fetch(:application)}/git-ssh.sh"
    end
  end

  desc 'Check that the repository is reachable'
  task check: :'gitbuild:wrapper' do
    fetch(:branch)
    run_locally do
      with fetch(:git_environmental_variables) do
        strategy.check
      end
    end
  end

  desc 'Clone the repo to the cache'
  task clone: :'gitbuild:wrapper' do
    run_locally do
      execute :mkdir, '-p', repo_path
      if strategy.test
        info t(:mirror_exists, at: repo_path)
      else
        within repo_path do
          with fetch(:git_environmental_variables) do
            strategy.clone
          end
        end
      end
    end
  end

  desc 'Update the repo mirror to reflect the origin state'
  task update: :'gitbuild:clone' do
    run_locally do
      within repo_path do
        with fetch(:git_environmental_variables) do
          strategy.update
        end
      end
    end
  end

  desc 'Create tarfile'
  task :create_tarfile => [:'gitbuild:update', :'gitbuild:set_current_revision'] do
    run_locally do
      within repo_path do
        with fetch(:git_environmental_variables) do
          strategy.release
          invoke 'gitbuild:build'
          execute :tar, '--create --verbose --file', strategy.local_tarfile, '--directory', strategy.local_build_path, '.'
        end
      end
    end
  end

  desc 'Build hook'
  task :build do
    # Custom build logic, to be implemented by the project which uses this deploy strategy.
    # 
    # Implement like:
    # |  namespace :gitbuild do
    # |    task :build do
    # |      run_locally do
    # |        execute :jekyll, "build -s '#{fetch(:repo_path)}' -d '#{fetch(:repo_path)}/_site'"
    # |      end
    # |    end
    # |  end
  end

  desc 'Copy repo to releases'
  task create_release: :'gitbuild:create_tarfile' do
    on release_roles :all do
      within deploy_to do
        execute :mkdir, '-p', release_path
        upload! strategy.local_tarfile, strategy.remote_tarfile
        execute :tar, '--extract --verbose --file', strategy.remote_tarfile, '--directory', release_path
        execute :rm, strategy.remote_tarfile
      end
    end

    run_locally do
      if File.exists? strategy.local_tarfile
        execute :rm, strategy.local_tarfile
      end
      if Dir.exists? strategy.local_build_path
        execute :rm, '-r', strategy.local_build_path
      end
    end
  end

  desc 'Determine the revision that will be deployed'
  task :set_current_revision do
    run_locally do
      with fetch(:git_environmental_variables) do
        set :current_revision, strategy.fetch_revision
      end
    end
  end
end
