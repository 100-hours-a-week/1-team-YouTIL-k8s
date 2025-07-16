# YouTIL Backend Helm Chart (GCP Optimized)

이 헬름 차트는 YouTIL 백엔드 애플리케이션을 Google Cloud Platform의 Kubernetes(GKE)에 배포하기 위한 것입니다.

## 요구사항

- Google Kubernetes Engine (GKE) 1.19+
- Helm 3.0+
- Google Cloud Artifact Registry 접근 권한
- GCP Load Balancer 권한

## 설치

### 기본 설치

```bash
# 기본 values로 설치 (LoadBalancer 사용)
helm install youtil-backend ./helm/be

# 프로덕션 환경으로 설치
helm install youtil-backend-prod ./helm/be -f ./helm/be/values-prod.yaml

# 개발 환경으로 설치
helm install youtil-backend-dev ./helm/be -f ./helm/be/values-dev.yaml
```

### 네임스페이스 지정

```bash
# 특정 네임스페이스에 설치
helm install youtil-backend ./helm/be --namespace youtil-prod --create-namespace
```

## 업그레이드

```bash
# 차트 업그레이드
helm upgrade youtil-backend ./helm/be

# 특정 values 파일로 업그레이드
helm upgrade youtil-backend ./helm/be -f ./helm/be/values-prod.yaml
```

## 제거

```bash
helm uninstall youtil-backend
```

## 설정

### 주요 설정 옵션

| 파라미터 | 설명 | 기본값 |
|---------|------|--------|
| `replicaCount` | 레플리카 수 | `1` |
| `image.repository` | GCP Artifact Registry 이미지 저장소 | `asia-northeast3-docker.pkg.dev/noted-hangout-464805-q6/youtil-docker-registry/youtil-be-prod` |
| `image.tag` | 도커 이미지 태그 | `latest` |
| `service.type` | 서비스 타입 | `LoadBalancer` |
| `service.port` | 서비스 포트 | `80` |
| `service.targetPort` | 컨테이너 포트 | `8080` |
| `service.loadBalancerIP` | GCP Load Balancer IP | `""` (자동 할당) |
| `ingress.enabled` | Ingress 활성화 | `false` (LoadBalancer 사용 시) |
| `resources.limits.cpu` | CPU 제한 | `500m` |
| `resources.limits.memory` | 메모리 제한 | `512Mi` |
| `hpa.enabled` | HPA 활성화 | `false` |

### GCP 특화 설정

```yaml
# LoadBalancer 서비스 설정
service:
  type: LoadBalancer
  loadBalancerIP: ""  # GCP에서 자동 할당

# GCP 노드 선택자
nodeSelector:
  cloud.google.com/gke-nodepool: "default-pool"

# GCP 특화 어노테이션
podAnnotations:
  cloud.google.com/load-balancer-type: "External"
```

### 환경 변수 설정

```yaml
env:
  - name: DATABASE_URL
    value: "postgresql://user:password@host:port/database"
  - name: REDIS_URL
    value: "redis://host:port"
  - name: NODE_ENV
    value: "production"
```

### ConfigMap 설정

```yaml
configMap:
  enabled: true
  data:
    config.yaml: |
      database:
        host: localhost
        port: 5432
      redis:
        host: localhost
        port: 6379
```

### Secret 설정

```yaml
secret:
  enabled: true
  data:
    database-password: base64-encoded-password
    api-key: base64-encoded-api-key
```

## 헬스 체크

애플리케이션은 `/health` 엔드포인트를 통해 헬스 체크를 수행합니다.

- **Liveness Probe**: 애플리케이션이 살아있는지 확인
- **Readiness Probe**: 애플리케이션이 요청을 처리할 준비가 되었는지 확인

## 자동 스케일링

HPA(Horizontal Pod Autoscaler)를 통해 CPU 및 메모리 사용률에 따른 자동 스케일링이 가능합니다.

```yaml
hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

## GCP Load Balancer

이 헬름 차트는 GCP Cloud Load Balancer를 사용합니다:

- **외부 Load Balancer**: 인터넷에서 접근 가능
- **자동 IP 할당**: GCP에서 자동으로 외부 IP 할당
- **고정 IP**: 필요시 `service.loadBalancerIP`에 고정 IP 지정

## 모니터링

애플리케이션 상태를 확인하는 방법:

```bash
# 파드 상태 확인
kubectl get pods -l app.kubernetes.io/name=youtil-backend

# 서비스 상태 확인 (LoadBalancer IP 확인)
kubectl get services -l app.kubernetes.io/name=youtil-backend

# 로그 확인
kubectl logs -f deployment/youtil-backend

# 헬스 체크 확인
kubectl exec -it <pod-name> -- curl http://localhost:8080/health

# LoadBalancer IP로 직접 접근
curl http://<load-balancer-ip>/health
```

## 트러블슈팅

### 일반적인 문제들

1. **이미지 풀 에러**
   - GCP Artifact Registry 인증 확인
   - `imagePullSecrets` 설정 확인
   - GKE 노드에 적절한 권한 부여

2. **LoadBalancer 생성 실패**
   - GCP 프로젝트에 LoadBalancer 권한 확인
   - 네트워크 설정 확인
   - 방화벽 규칙 확인

3. **헬스 체크 실패**
   - 애플리케이션이 `/health` 엔드포인트를 제공하는지 확인
   - 포트 설정 확인

4. **HPA 작동 안함**
   - metrics-server 설치 확인
   - 리소스 요청/제한 설정 확인

## GCP 특화 고려사항

1. **비용 최적화**
   - 적절한 리소스 요청/제한 설정
   - HPA를 통한 자동 스케일링 활용
   - 불필요한 LoadBalancer 제거

2. **보안**
   - GCP IAM 역할 최소 권한 원칙 적용
   - 네트워크 정책 설정
   - Secret 관리

3. **모니터링**
   - GCP Cloud Monitoring 연동
   - 로그는 Cloud Logging으로 전송

## 지원

문제가 발생하면 다음을 확인하세요:

1. Kubernetes 이벤트: `kubectl get events`
2. 파드 로그: `kubectl logs <pod-name>`
3. 서비스 상태: `kubectl describe service <service-name>`
4. GCP LoadBalancer 상태: GCP Console에서 확인
5. GCP Cloud Logging: 애플리케이션 로그 확인 