"""
Pipelines allow putting together Components to build a graph.

In addition to the standard Haystack Components, custom user-defined Components
can be used in a Pipeline YAML configuration.

The classes for the Custom Components must be defined in this file.
"""


from haystack.nodes.base import BaseComponent

print("WARNING: This is a custom component that should not be loaded")


class SampleComponent(BaseComponent):
    outgoing_edges: int = 1

    def run(self, **kwargs):
        raise NotImplementedError
