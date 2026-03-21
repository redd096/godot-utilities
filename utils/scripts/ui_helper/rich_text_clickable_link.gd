class_name RichTextClickableLink extends Node

@export var richtextlabel: RichTextLabel

func _ready():
	# Connect the `meta_clicked` signal to the `_richtextlabel_on_meta_clicked` method
	richtextlabel.meta_clicked.connect(_richtextlabel_on_meta_clicked)

func _richtextlabel_on_meta_clicked(meta):
	# `meta` is of Variant type, so convert it to a String to avoid script errors at run-time.
	OS.shell_open(str(meta))