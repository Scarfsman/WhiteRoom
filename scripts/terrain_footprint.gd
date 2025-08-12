extends Polygon2D

func setCollider(layer = 1) -> void:
    var collision_shape = CollisionPolygon2D.new()
    collision_shape.polygon = polygon
    $StaticBody2D.add_child(collision_shape)
    print(layer)
    $StaticBody2D.collision_layer = layer
    print($StaticBody2D.collision_layer)
