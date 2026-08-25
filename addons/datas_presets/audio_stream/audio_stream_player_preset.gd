@tool
class_name AudioStreamPlayerPreset 
extends BaseDataPreset
## Single preset to add in database resource

enum EType { AudioStreamPlayer, AudioStreamPlayer3D, AudioStreamPlayer2D }
## For now this is used only to show correctly volume_db range
@export var type: EType:
    set(new_value):
        if type != new_value:
            type = new_value
            notify_property_list_changed()  # call _validate_property function
            emit_changed()

## See [member AudioStreamPlayer.stream]
@export var stream: AudioStream:
    set(new_value):
        if stream != new_value:
            stream = new_value
            emit_changed()

## See [member AudioStreamPlayer.volume_db]
@export var volume_db: float = 1.0:
    set(new_value):
        if volume_db != new_value:
            volume_db = new_value
            emit_changed()

## See [member AudioStreamPlayer.bus]
@export var bus: StringName = "Master":
    set(new_value):
        if bus != new_value:
            bus = new_value
            emit_changed()


func _validate_property(property: Dictionary) -> void:    
    # for "volume_db" show range from -80 to "80 if 3D, else 24" like it works in godot inspector
    if property.name == &"volume_db":
        var max_volume_db: float = 80.0 if type == EType.AudioStreamPlayer3D else 24.0
        volume_db = minf(volume_db, max_volume_db)  # update also variable value, not only inspector ui

        property.hint = PROPERTY_HINT_RANGE
        property.hint_string = "-80.0, %s, 0.001, suffix:dB" % max_volume_db

    # for property "bus", show dropdown of every Audio Bus in godot
    elif property.name == &"bus":
        var audio_buses := PackedStringArray()
        for bus_index in range(AudioServer.get_bus_count()):
            audio_buses.append(AudioServer.get_bus_name(bus_index))
            
        property.hint = PROPERTY_HINT_ENUM
        property.hint_string = ",".join(audio_buses)


func apply_values(node: Object) -> bool:
    var applied: bool

    if  &"stream" in node:
        node.stream = stream
        applied = true
        
    if  &"volume_db" in node:
        node.volume_db = volume_db
        applied = true
        
    if  &"bus" in node:
        node.bus = bus
        applied = true

    return applied


# tutte le variabili
    # X ------------- tutti.stream
    # 3d.attenuation_model
    # X ------------- tutti.volume_db
    # 3d.unit_size: float @export_range(0.1, 100.0, 0.01)
    # 3d.max_db: float @export_range(-24.0, 6.0, 0.001, suffix:dB)
    # tutti.pitch_scale: float @export_range(0.01, 4.0, 0.01)
    # tutti.autoplay: bool
    # 3d AND 2d.max_distance
    # 2d.attenuation
    # SOLO streamplayer.mix_target
    # tutti.max_polyphony
    # 3d AND 2d.panning_strength
    # X ------------- tutti.bus
    # export_flags_3d_physics 3d.area_mask
    # export_flags_2d_physics 2d.area_mask
    # tutti.playback_type

    # @export_group("Emission Angle")
    # sulla stessa riga del group, dovrebbe esserci anche una checkbox per emission_angle_enabled, e le prossime 2 sono visibili solo se è true
    # 3d.emission_angle_degrees
    # 3d.emission_angle_filter_attenuation_db

    # @export_group("Attenuation Filter")
    # 3d.attenuation_filter_cutoff_hz
    # 3d.attenuation_filter_db

    # @export_group("Doppler")
    # 3d.doppler_tracking
