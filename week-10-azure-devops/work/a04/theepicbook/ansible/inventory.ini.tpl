[frontend]
epicbook-frontend ansible_host=__APP_PUBLIC_IP__

[backend]
epicbook-backend ansible_host=__BACKEND_PRIVATE_IP__

[epicbook:children]
frontend
backend
