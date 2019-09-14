def label = "worker-${UUID.randomUUID().toString()}"

podTemplate(label: label, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'maven', image: 'maven:3.6.2-jdk-8', command: 'cat', ttyEnabled: true),
  containerTemplate(name: 'helm', image: 'lachlanevenson/k8s-helm:latest', command: 'cat', ttyEnabled: true)
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
    // stage('Unit Test with Maven') {
    //   container('maven') {
    //     sh "mvn test"
    //   }
    // }
    // stage('Code Quality with Sonar'){
    //     container('maven'){
    //         //TODO: get sonar registry via Jenkins env variable
    //         sh "mvn sonar:sonar -Dsonar.host.url=https://sonarqube-cid.arakaki.in -Dsonar.login=33e30ea684e5636af4d7ec8b12c8ed67bba1fde3"
    //     }
    // }
    stage('Create Docker images') {
      if(env.BRANCH_NAME == 'dev'){
        container('docker') {
          withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: '	apiuser-harbor-registry',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASSWORD']]){
          //TODO: get harbor registry via Jenkins env variable
              sh """
              docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} https://harbor.arakaki.in
              docker build -t harbor.arakaki.in/project/springboot-example-app:${gitCommit} .
              docker push harbor.arakaki.in/project/springboot-example-app:${gitCommit}
              """
          }
        }
      } else if (env.BRANCH_NAME == 'master') {
        container('docker') {
          withCredentials([[$class: 'UsernamePasswordMultiBinding',
          credentialsId: '	apiuser-harbor-registry',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASSWORD']]){
          //TODO: get harbor registry via Jenkins env variable
            sh """
            docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} https://harbor.arakaki.in
            docker build -t harbor.arakaki.in/project/springboot-example-app:stable-${gitCommit} .
            docker push harbor.arakaki.in/project/springboot-example-app:stable-${gitCommit}
            """
          }
        }
      }
    }
    stage('Helm Upgrade') {
      if(env.BRANCH_NAME == 'dev'){
        container('helm') {
          sh "helm upgrade app-dev-release ./springboot-example-app-chart --namespace dev --set=image.tag=${gitCommit} --set=canary.enabled=false --set=virtualService.enabled=true --set=virtualService.host=backend-spring-dev.arakaki.in"
        }
      } else if (env.BRANCH_NAME == 'master') {
        container('helm') {
          sh "helm upgrade app-prd-release ./springboot-example-app-chart --namespace prd --set=image.tag=stable-${gitCommit} --set=canary.enabled=true --set=canary.virtualService.enabled=true --set=canary.virtualService.host=backend-spring.arakaki.in --namespace prd"
        }
      }
    }
  }
}