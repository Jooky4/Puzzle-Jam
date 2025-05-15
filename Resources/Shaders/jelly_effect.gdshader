shader_type canvas_item;

uniform vec2 velocity; // Скорость движения блока (передаётся из GDScript)
uniform vec2 last_velocity; // Последняя ненулевая скорость (для направления колебаний)
uniform float amplitude : hint_range(0.0, 0.1) = 0.03; // Амплитуда "желейности"
uniform float damping : hint_range(0.0, 2.0) = 0.9; // Затухание эффекта
uniform float oscillation_strength : hint_range(0.0, 1.0) = 0.0; // Сила колебаний (0 - нет, 1 - максимум)
uniform float oscillation_frequency : hint_range(0.0, 20.0) = 10.0; // Частота колебаний
uniform float oscillation_decay : hint_range(0.0, 1.0) = 0.5; // Скорость затухания колебаний
uniform float stop_time : hint_range(0.0, 100000.0) = 0.0; // Время с момента остановки

void vertex() {
    // UV.y = 0 вверху, UV.y = 1 внизу
    float jelly_factor = (1.0 - UV.y) * amplitude;

    // Эффект движения (основной эффект желе)
    VERTEX -= velocity * jelly_factor * damping;

    // Эффект колебаний после остановки
    if (oscillation_strength > 0.0) {
        // Время с момента остановки
        float time_since_stop = TIME - stop_time;
        // Колебания с затуханием
        float oscillation = sin(time_since_stop * oscillation_frequency) * oscillation_strength * exp(-oscillation_decay * time_since_stop);
        // Направление колебаний зависит от последней скорости
        VERTEX -= normalize(last_velocity) * oscillation * jelly_factor * damping;
    }
}