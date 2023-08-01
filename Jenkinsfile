pipeline {
    agent { node { label 'DockerBuildImage' } }
    environment {
		DOCKER_SERVER = 'docker.allocate-cloud.co.uk:5000'
        BUILD_USER = credentials('build')
        BUILD_RLD_USER = credentials('build-rld')
        BUILD_GITHUB_PAT = credentials('github-build-userpass')
        SYSPREP_USER = credentials('windows-sysprep')
        AWS_ACCESS_KEY = credentials('aws-build-accesskey')
        AWS_SECRET_ACCESS_KEY = credentials('aws-build-secretaccesskey')
    }
    stages {
        stage('build') {
            steps {
				sh """
                    docker login -u "${env.BUILD_USER_USR}" -p "${env.BUILD_USER_PSW}" ${DOCKER_SERVER}
                """
                sh """
                    docker run \
                    --rm \
                    -e AWS_MAX_ATTEMPTS=90 \
                    -e AWS_POLL_DELAY_SECONDS=60 \
                    -e AWS_ACCESS_KEY_ID=${env.AWS_ACCESS_KEY} \
                    -e AWS_SECRET_ACCESS_KEY=${env.AWS_SECRET_ACCESS_KEY} \
                    -v ${env.WORKSPACE}:/workspace \
                    -w /workspace \
                    docker.allocate-cloud.co.uk:5000/asw/devops/packer-ansible-builder:latest \
                    build -var build_pw="${env.BUILD_USER_PSW}" -var build_rld_pw="${env.BUILD_RLD_USER_PSW}" -var build_github_pat="${env.BUILD_GITHUB_PAT}" -var sysprep_pw="${env.SYSPREP_USER_PSW}" -debug healthroster-build-agent-w2016.json
                """
            }
        }
    }
	post {
		cleanup {
			pwsh 'docker image prune -a'
			script {
				if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'develop' || env.BRANCH_NAME == 'assemble' || env.BRANCH_NAME.startsWith('release')) {
					echo "git cleaning ${WORKSPACE}"
					pwsh 'git clean -ffdx'
				}
				else {
					echo "Deleting ${WORKSPACE}"
					deleteDir()
				}				
			}
		}
    }
}
