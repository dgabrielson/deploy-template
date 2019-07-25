#!/usr/bin/env python
from __future__ import unicode_literals, print_function

import os
import re

from cluster_conf_fmt import CLUSTER_CONF_FMT


def cluster_conf_dict(f):
    result = {}
    with open(f) as fp:
        for line in fp:
            line = line.strip()
            if line.startswith('#'):
                continue
            d = dict(zip(CLUSTER_CONF_FMT, line.split('\t')))
            result[d['name']] = {k:d[k] if d[k] != 'X' else None for k in d}
    return result


def get_graph_label():
    title = os.path.join(os.getcwd(), __file__)
    title = os.path.realpath(title)
    title = os.path.split(title)[0]
    title = os.path.split(title)[0]
    title = os.path.split(title)[1]
    return title.title()


def _dot_pre():
    result = 'graph clustermap {\n'
    #result += 'rankdir=RL;\n'
    result += 'layout=fdp;\n'
    label = get_graph_label()
    result += 'graph [label="{}", labelloc=t, fontsize=36];\n'.format(label)
    return result


def _dot_post(extra):
    result = ''
    for k, v in extra["subgraph"].items():
        result += '\nsubgraph cluster_{} {{\n'.format(k.replace('-', '_'))
        result += '\ngraph [label=""];'
        result += '\n'.join(v)
        result += '\n}'
    for v in extra["same-rank"].values():
        result += '\n{{rank=same; {}}}'.format(''.join(['"{}"; '.format(n) for n in v]))
    result += '\n}\n'
    return result


def _dot_value(hostinfo, extra):
    if 'subgraph' not in extra:
        extra['subgraph'] = {}
    if 'same-rank' not in extra:
        extra['same-rank'] = {}
    phys_host = hostinfo.get('phys-host')
    name = hostinfo.get('name')
    services = hostinfo.get('services')
    if services is None:
        services = ''
    services = services.split(',')
    if phys_host is None:
        if '_phys' not in extra['same-rank']:
            extra['same-rank']['_phys'] = []
        extra['same-rank']['_phys'].append(name)
    else:
        if phys_host not in extra['same-rank']:
            extra['same-rank'][phys_host] = []
        extra['same-rank'][phys_host].append(name)
    attrs = 'shape='
    if phys_host is None:
        attrs += 'box3d'
    else:
        attrs += 'oval'
    node = '"{}"'.format(name)
    if attrs:
        node += ' [{}]'.format(attrs)
    node += ';'
    result = ''
    if phys_host is not None:
        if phys_host not in extra['subgraph']:
            extra['subgraph'][phys_host] = []
        extra['subgraph'][phys_host].append(node)
        edge = '\n"{}" -- "{}";'.format(name, phys_host)
        extra['subgraph'][phys_host].append(edge)
    else:
        result = node

    # including docker edges can result in stupidly large graphs
    if '_docker_node' in extra and 'swarmmgr' in services:
        result += '\n"{}" -- "{}" [style=dashed];'.format(name, extra['_docker_node'])
    if '_docker_node' in extra and 'docker' in services:
        result += '\n"{}" -- "{}" [style=dashed];'.format(name, extra['_docker_node'])
    if '_docker_node' in extra and 'swarmwrkr' in services:
        result += '\n"{}" -- "{}" [style=dotted];'.format(name, extra['_docker_node'])

    return result, extra


def data2dot(data, docker_data):
    result = []
    result.append(_dot_pre())
    extra = {}
    if docker_data:
        extra['_docker_node'] = 'struct1'
    for k,v in sorted(data.items(), key=lambda (k,v): v['ip-address']):
        v = data[k]
        s, extra = _dot_value(v, extra)
        result.append(s)

    if docker_data:
        s = 'struct1 [label="DOCKER|{{{0}}}" shape=Mrecord];'.format('|'.join(docker_data));
        extra['same-rank']['_docker'] = ['struct1', ]
        result.append(s)

    result.append(_dot_post(extra))
    return '\n'.join(result)


def find_docker_services(docker_local_fn):
    if not os.path.exists(docker_local_fn):
        return None
    expr = r'docker\.([^:\s]*)\.script.evt'
    text = open(docker_local_fn).read()
    # exclude commented lines
    text = '\n'.join([l for l in text.split('\n') if not l.strip().startswith('#')])
    p = re.compile(expr)
    svc_list = set(p.findall(text))
    # TODO: ports, container, service, or stack?
    return sorted(svc_list)


def main(script):
    """
    """
    absscript = os.path.abspath(script)
    dirname = os.path.dirname(absscript)
    parent = os.path.dirname(dirname)
    cluster_conf = os.path.join(parent, 'cluster.conf')
    data = cluster_conf_dict(cluster_conf)
    docker_local = os.path.join(parent, 'cntrm00', 'docker_local.make')
    docker_data = find_docker_services(docker_local)
    return data2dot(data, docker_data)


if __name__ == '__main__':
    import sys
    print(main(*sys.argv))
