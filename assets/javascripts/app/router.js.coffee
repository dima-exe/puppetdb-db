window.App.Router = Backbone.Router.extend

  routes:
    ""                    : "dashboard"
    "/"                   : "dashboard"
    "nodes/:node"        : "node"
    "nodes/:node/reports": "nodeReports"

  initialize:(options) ->
    @nodes   = options.nodes
    @navView = new App.NavView()
    @navView.render()

    @dashboardView     = new App.DashboardView(nodes: @nodes)
    @nodeView          = new App.NodeView()
    @nodeReportsView   = new App.NodeReportsView()

  dashboard: ->
    @navView.render()
    @dashboardView.activate()

  node: (nodeName) ->
    node = @nodes.findByName(nodeName)
    @navView.render(node: node)
    @nodeView.activate(node)

  nodeReports: (nodeName) ->
    node = @nodes.findByName(nodeName)
    @navView.render(node: node, reports: true)
    @nodeReportsView.activate(node)

$(document).ready ->
  nodes = new App.NodesCollection()
  nodes.fetch().success ->
    window.appRouter = new App.Router(nodes: nodes)
    Backbone.history.start(pushState: true, root: "/ui/")

  $("body").on "click", "a", (ev) ->
    el = $(ev.currentTarget)
    window.appRouter.navigate(el.attr("href"), trigger: true)
    false