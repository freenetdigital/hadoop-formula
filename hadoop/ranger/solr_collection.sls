{%- from 'hadoop/ranger/settings.sls' import ranger      with context %}
{%- from 'hadoop/solr/settings.sls'   import solr        with context %}

#to be run on a solr host
deploy-solr-conf:
  archive.extracted:
    - name: /tmp/ranger-solr-conf
    - source: salt://ranger/ranger-{{ ranger.version }}/ranger-{{ ranger.version }}-admin.zip
    - archive_format: zip 
    - clean: true
    - user: solr
    - group: solr

create-solr-collection:
  cmd.run:
    - name: {{ solr.install_dir }}/bin/solr create_collection -c ranger_audits -d /tmp/ranger-solr-conf/ranger-{{ ranger.version }}-admin/contrib/solr_for_audit_setup/conf -shards 1 -replicationFactor 1

