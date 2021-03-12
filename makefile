DOCKER := docker
COMMIT := $(shell git rev-parse --short HEAD)
REVISION := "eval $$\( aws ecs register-task-definition  --cli-input-json file://taskdef.json | jq '.taskDefinition.revision'\)"
REVISION1 := $(shell aws ecs register-task-definition  --cli-input-json file://taskdef.json | jq '.taskDefinition.revision')
SHORT_SHA=$(COMMIT)

docker-build-image:
	${DOCKER} build -t ${ECR_REPO}:${SHORT_SHA} . --build-arg BUILD="${CIRCLE_BUILD_NUM}"
	${DOCKER} tag ${ECR_REPO}:${SHORT_SHA} ${AWS_ECR_ACCOUNT_URL}/${ECR_REPO}:${SHORT_SHA}
	${DOCKER} tag ${ECR_REPO}:${SHORT_SHA} ${AWS_ECR_ACCOUNT_URL}/${ECR_REPO}:latest


docker-repo-login:
	eval $$\( aws ecr get-login --no-include-email --region ${REGION}\)

publish: docker-repo-login
	${DOCKER} push ${AWS_ECR_ACCOUNT_URL}/${ECR_REPO}:${SHORT_SHA}
	${DOCKER} push ${AWS_ECR_ACCOUNT_URL}/${ECR_REPO}:latest

deploy-service:
	aws configure set default.region ${REGION}
	$(eval REVISION=$(shell aws ecs register-task-definition  --cli-input-json file://taskdef.json | jq '.taskDefinition.revision') )
	echo "REVISION is : ${REVISION}"
	aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE} --task-definition nginx:${REVISION} --force-new-deployment