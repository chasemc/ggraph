#' Draw edges as Arcs
#'
#' This geom is mainly intended for arc linear and circular diagrams (i.e. used
#' together with [layout_tbl_graph_linear()]), though it can be used
#' elsewere. It draws edges as arcs with a hight proportional to the distance
#' between the nodes. Arcs are calculated as beziers. For linear layout the
#' placement of control points are related to the `curvature` argument and
#' the distance between the two nodes. For circular layout the control points
#' are placed on the same angle as the start and end node at a distance related
#' to the distance between the nodes.
#'
#' @inheritSection geom_edge_link Edge variants
#' @inheritSection geom_edge_link Edge aesthetic name expansion
#'
#' @section Aesthetics:
#' `geom_edge_arc` and `geom_edge_arc0` understand the following
#' aesthetics. Bold aesthetics are automatically set, but can be overridden.
#'
#' - **x**
#' - **y**
#' - **xend**
#' - **yend**
#' - **circular**
#' - edge_colour
#' - edge_width
#' - edge_linetype
#' - edge_alpha
#' - filter
#'
#' `geom_edge_arc2` understand the following aesthetics. Bold aesthetics are
#' automatically set, but can be overridden.
#'
#' - **x**
#' - **y**
#' - **group**
#' - **circular**
#' - edge_colour
#' - edge_width
#' - edge_linetype
#' - edge_alpha
#' - filter
#'
#' `geom_edge_arc` and `geom_edge_arc2` furthermore takes the following
#' aesthetics.
#'
#' - start_cap
#' - end_cap
#' - label
#' - label_pos
#' - label_size
#' - angle
#' - hjust
#' - vjust
#' - family
#' - fontface
#' - lineheight
#'
#'
#' @section Computed variables:
#'
#' \describe{
#'  \item{index}{The position along the path (not computed for the *0 version)}
#' }
#'
#' @inheritParams geom_edge_link
#' @inheritParams ggplot2::geom_path
#'
#' @param curvature The bend of the curve. 1 approximates a halfcircle while 0
#' will give a straight line. Negative number will change the direction of the
#' curve. Only used if `circular = FALSE`.
#'
#' @param fold Logical. Should arcs appear on the same side of the nodes despite
#' different directions. Default to `FALSE`.
#'
#' @author Thomas Lin Pedersen
#'
#' @family geom_edge_*
#'
#' @examples
#' require(tidygraph)
#' # Make a graph with different directions of edges
#' gr <- create_notable('Meredith') %>%
#'   convert(to_directed) %>%
#'   mutate(class = sample(letters[1:3], n(), replace = TRUE)) %>%
#'   activate(edges) %>%
#'   mutate(class = sample(letters[1:3], n(), replace = TRUE),
#'          switch = sample(c(TRUE, FALSE), n(), replace = TRUE)) %>%
#'   reroute(from = to, to = from, subset = switch)
#'
#' ggraph(gr, 'linear') +
#'   geom_edge_arc(aes(alpha = ..index..))
#'
#' ggraph(gr, 'linear') +
#'   geom_edge_arc2(aes(colour = node.class), curvature = 0.6)
#'
#' ggraph(gr, 'linear', circular = TRUE) +
#'   geom_edge_arc0(aes(colour = class))
#'
#' @rdname geom_edge_arc
#' @name geom_edge_arc
#'
NULL

#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier
#' @export
StatEdgeArc <- ggproto('StatEdgeArc', StatBezier,
    setup_data = function(data, params) {
        if (any(names(data) == 'filter')) {
            if (!is.logical(data$filter)) {
                stop('filter must be logical')
            }
            data <- data[data$filter, names(data) != 'filter']
        }
        data$group <- seq_len(nrow(data))
        data2 <- data
        data2$x <- data2$xend
        data2$y <- data2$yend
        data$xend <- NULL
        data$yend <- NULL
        data2$xend <- NULL
        data2$yend <- NULL
        createArc(data, data2, params)
    },
    required_aes = c('x', 'y', 'xend', 'yend', 'circular'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'n', 'curvature', 'fold')
)
#' @rdname geom_edge_arc
#'
#' @export
geom_edge_arc <- function(mapping = NULL, data = get_edges(),
                          position = "identity", arrow = NULL, curvature = 1,
                          n = 100, fold = FALSE, lineend = "butt",
                          linejoin = "round", linemitre = 1,
                          label_colour = 'black',  label_alpha = 1,
                          label_parse = FALSE, check_overlap = FALSE,
                          angle_calc = 'rot', force_flip = TRUE,
                          label_dodge = NULL, label_push = NULL,
                          show.legend = NA, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, xend=~xend, yend=~yend,
                                          circular=~circular))
    layer(data = data, mapping = mapping, stat = StatEdgeArc,
          geom = GeomEdgePath, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, linejoin = linejoin,
                   linemitre = linemitre, na.rm = FALSE, n = n,
                   interpolate = FALSE, curvature = curvature, fold = fold,
                   label_colour = label_colour, label_alpha = label_alpha,
                   label_parse = label_parse, check_overlap = check_overlap,
                   angle_calc = angle_calc, force_flip = force_flip,
                   label_dodge = label_dodge, label_push = label_push, ...)
          )
    )
}
#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier2
#' @export
StatEdgeArc2 <- ggproto('StatEdgeArc2', StatBezier2,
    setup_data = function(data, params) {
        if (any(names(data) == 'filter')) {
            if (!is.logical(data$filter)) {
                stop('filter must be logical')
            }
            data <- data[data$filter, names(data) != 'filter']
        }
        data <- data[order(data$group),]
        data2 <- data[c(FALSE, TRUE), ]
        data <- data[c(TRUE, FALSE), ]
        createArc(data, data2, params)
    },
    required_aes = c('x', 'y', 'group', 'circular'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'n', 'curvature', 'fold')
)
#' @rdname geom_edge_arc
#'
#' @export
geom_edge_arc2 <- function(mapping = NULL, data = get_edges('long'),
                           position = "identity", arrow = NULL, curvature = 1,
                           n = 100, fold = FALSE, lineend = "butt",
                           linejoin = "round", linemitre = 1,
                           label_colour = 'black',  label_alpha = 1,
                           label_parse = FALSE, check_overlap = FALSE,
                           angle_calc = 'rot', force_flip = TRUE,
                           label_dodge = NULL, label_push = NULL,
                           show.legend = NA, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, group=~edge.id,
                                          circular=~circular))
    layer(data = data, mapping = mapping, stat = StatEdgeArc2,
          geom = GeomEdgePath, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, linejoin = linejoin,
                   linemitre = linemitre, na.rm = FALSE, n = n,
                   interpolate = TRUE, curvature = curvature, fold = fold,
                   label_colour = label_colour, label_alpha = label_alpha,
                   label_parse = label_parse, check_overlap = check_overlap,
                   angle_calc = angle_calc, force_flip = force_flip,
                   label_dodge = label_dodge, label_push = label_push, ...)
          )
    )
}
#' @rdname ggraph-extensions
#' @format NULL
#' @usage NULL
#' @importFrom ggforce StatBezier0
#' @export
StatEdgeArc0 <- ggproto('StatEdgeArc0', StatBezier0,
    setup_data = function(data, params) {
        StatEdgeArc$setup_data(data, params)
    },
    required_aes = c('x', 'y', 'xend', 'yend', 'circular'),
    default_aes = aes(filter = TRUE),
    extra_params = c('na.rm', 'curvature', 'fold')
)
#' @rdname geom_edge_arc
#'
#' @export
geom_edge_arc0 <- function(mapping = NULL, data = get_edges(),
                           position = "identity", arrow = NULL, curvature = 1,
                           lineend = "butt", show.legend = NA, fold = fold, ...) {
    mapping <- completeEdgeAes(mapping)
    mapping <- aesIntersect(mapping, aes_(x=~x, y=~y, xend=~xend, yend=~yend,
                                          circular=~circular))
    layer(data = data, mapping = mapping, stat = StatEdgeArc0,
          geom = GeomEdgeBezier, position = position, show.legend = show.legend,
          inherit.aes = FALSE,
          params = expand_edge_aes(
              list(arrow = arrow, lineend = lineend, na.rm = FALSE,
                   curvature = curvature, fold = FALSE, ...)
          )
    )
}

createArc <- function(from, to, params) {
    bezierStart <- seq(1, by=4, length.out = nrow(from))
    from$index <- bezierStart
    to$index <- bezierStart + 3
    data2 <- from
    data3 <- to
    data2$index <- bezierStart + 1
    data3$index <- bezierStart + 2
    nodeDist <- sqrt((to$x - from$x)^2 + (to$y - from$y)^2) / 2
    circ <- from$circular
    if (any(circ)) {
        r0 <- sqrt(to$x[circ]^2 + to$y[circ]^2)
        r1 <- sqrt(to$x[circ]^2 + to$y[circ]^2)

        data2$x[circ] <- from$x[circ] * (1 - (nodeDist[circ]/r0))
        data2$y[circ] <- from$y[circ] * (1 - (nodeDist[circ]/r0))
        data3$x[circ] <- to$x[circ] * (1 - (nodeDist[circ]/r1))
        data3$y[circ] <- to$y[circ] * (1 - (nodeDist[circ]/r1))
    }
    if (any(!circ)) {
        curvature <- pi/2 * -params$curvature
        edgeAngle <- atan2(to$y[!circ] - from$y[!circ],
                           to$x[!circ] - from$x[!circ])
        startAngle <- edgeAngle - curvature
        endAngle <- edgeAngle - pi + curvature
        data2$x[!circ] <- data2$x[!circ] + cos(startAngle) * nodeDist[!circ]
        data2$y[!circ] <- data2$y[!circ] + sin(startAngle) * nodeDist[!circ]
        data3$x[!circ] <- data3$x[!circ] + cos(endAngle) * nodeDist[!circ]
        data3$y[!circ] <- data3$y[!circ] + sin(endAngle) * nodeDist[!circ]
        if (params$fold) {
            #data2$x[!circ] <- abs(data2$x[!circ]) * sign(params$curvature)
            data2$y[!circ] <- abs(data2$y[!circ]) * sign(params$curvature)
            #data3$x[!circ] <- abs(data3$x[!circ]) * sign(params$curvature)
            data3$y[!circ] <- abs(data3$y[!circ]) * sign(params$curvature)
        }
    }
    data <- rbind(from, data2, data3, to)
    data[order(data$index), names(data) != 'index']
}
