def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {
  node(label) {
    def myRepo = checkout scm
    def gitCommit = myRepo.GIT_COMMIT
    def gitBranch = myRepo.GIT_BRANCH
    def shortGitCommit = "${gitCommit[0..10]}"
    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
    def harborRegistry = "${HARBOR_REGISTRY}"
    stage('Create Docker images') {
      container('docker') {
        withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: '	apiuser-harbor-registry',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASSWORD']]){
            //echo "DOCKER_REGISTRY=${harborRegistry}" >> /etc/environment
            sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} https://harbor.arakaki.in"
            sh "docker build -t project/springboot-example-app:${gitCommit} ."
            sh "docker push harbor.arakaki.in/project/springboot-example-app:${gitCommit}"
        }
      }
    }
  }
}