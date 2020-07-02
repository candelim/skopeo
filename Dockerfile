FROM registry.access.redhat.com/ubi8/ubi-init
LABEL maintainer="Red Hat, Inc."

LABEL com.redhat.component="skopeo-container"
LABEL name="rhel8/skopeo"
LABEL version="8.2"

LABEL License="ASL 2.0"

#labels for container catalog
LABEL summary="Inspect container images and repositories on registries"
LABEL description="Command line utility to inspect images and repositories directly on registries without the need to pull them"
LABEL io.k8s.display-name="Skopeo"
LABEL io.openshift.expose-services=""

RUN useradd build; dnf -y module enable container-tools:rhel8; dnf -y update; dnf -y reinstall shadow-utils; dnf -y install skopeo fuse-overlayfs; rm -rf /var/cache /var/log/dnf* /var/log/yum.*

# Adjust storage.conf to enable Fuse storage.
RUN sed -i -e 's|^#mount_program|mount_program|g' -e '/additionalimage.*/a "/var/lib/shared",' /etc/containers/storage.conf
RUN mkdir -p /var/lib/shared/overlay-images /var/lib/shared/overlay-layers; touch /var/lib/shared/overlay-images/images.lock; touch /var/lib/shared/overlay-layers/layers.lock

# Set up environment variables to note that this is
# not starting with usernamespace and default to
# isolate the filesystem with chroot.
ENV _BUILDAH_STARTED_IN_USERNS="" BUILDAH_ISOLATION=chroot
