# Use EAP 8 Builder image to create a JBoss EAP 8 server
# with its default configuration
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-builder-openshift-rhel8:latest AS builder

# Set up environment variables for provisioning.
ENV GALLEON_PROVISION_FEATURE_PACKS org.jboss.eap:wildfly-ee-galleon-pack,org.jboss.eap.cloud:eap-cloud-galleon-pack
ENV GALLEON_PROVISION_LAYERS cloud-default-config
ENV GALLEON_PROVISION_CHANNELS org.jboss.eap.channels:eap-8.0

# Run the assemble script to provision the server.
RUN /usr/local/s2i/assemble



# Copy the JBoss EAP 8 server from the builder image to the runtime image.
FROM registry.redhat.io/jboss-eap-8/eap8-openjdk17-runtime-openshift-rhel8:latest AS runtime

# Set appropriate ownership and permissions.
COPY --from=builder --chown=jboss:root $JBOSS_HOME $JBOSS_HOME

# COPY the WAR/EAR to $JBOSS_HOME/standalone/deployments
COPY --chown=jboss:root target/helloworld-1.0-SNAPSHOT.war $JBOSS_HOME/standalone/deployments

# copy a modified standalone.xml in $JBOSS_HOME/standalone/configuration/
#COPY --chown=jboss:root standalone.xml  $JBOSS_HOME/standalone/configuration

# Ensure appropriate permissions for the copied files.
RUN chmod -R ug+rwX $JBOSS_HOME