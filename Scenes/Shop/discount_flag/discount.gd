class_name Discount extends Object

enum EType {
	DISCOUNT_10,
	DISCOUNT_20,
	DISCOUNT_30,
	DISCOUNT_40,
	DISCOUNT_50,
}

@export var type: EType

func get_text() -> String:
	return label_alias[type]
