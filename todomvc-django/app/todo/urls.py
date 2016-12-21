from django.conf.urls import include, url

# Import main view
from todo.views import Home

urlpatterns = [

    # Main page
    url(r'^$', Home.as_view()),

    # Include API URLs
    url(r'^api/', include('api.urls')),

    # Include auth URLs
    url(r'^auth/', include('rest_auth.urls')),
    url(r'^auth/signup/', include('rest_auth.registration.urls')),
]
