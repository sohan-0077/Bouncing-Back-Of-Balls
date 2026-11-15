extends Node2D

const W := 960.0
const H := 540.0
const PADDLE_W := 145.0
const PADDLE_H := 18.0
const BALL_R := 12.0
const BRICK_W := 82.0
const BRICK_H := 26.0

var paddle_x := W / 2.0
var ball := Vector2(W / 2.0, H - 105.0)
var velocity := Vector2(260.0, -300.0)
var bricks: Array[Rect2] = []
var score := 0
var lives := 3
var running := false
var ended := false

func _ready() -> void:
	new_game()

func new_game() -> void:
	score = 0
	lives = 3
	ended = false
	running = false
	paddle_x = W / 2.0
	ball = Vector2(W / 2.0, H - 105.0)
	velocity = Vector2(260.0, -300.0)
	bricks.clear()
	for row in range(5):
		for col in range(10):
			bricks.append(Rect2(52.0 + col * 86.0, 90.0 + row * 34.0, BRICK_W, BRICK_H))
	queue_redraw()

func _process(delta: float) -> void:
	if ended:
		queue_redraw()
		return
	var target := get_global_mouse_position().x
	if Input.is_action_pressed("ui_left"):
		target = paddle_x - 480.0 * delta
	elif Input.is_action_pressed("ui_right"):
		target = paddle_x + 480.0 * delta
	paddle_x = clampf(target, PADDLE_W / 2.0 + 12.0, W - PADDLE_W / 2.0 - 12.0)
	if running:
		ball += velocity * delta
		if ball.x < BALL_R or ball.x > W - BALL_R:
			velocity.x *= -1.0
			ball.x = clampf(ball.x, BALL_R, W - BALL_R)
		if ball.y < BALL_R + 42.0:
			velocity.y = absf(velocity.y)
		var paddle := Rect2(paddle_x - PADDLE_W / 2.0, H - 48.0, PADDLE_W, PADDLE_H)
		if velocity.y > 0.0 and paddle.intersects(Rect2(ball.x - BALL_R, ball.y - BALL_R, BALL_R * 2, BALL_R * 2)):
			var hit := (ball.x - paddle_x) / (PADDLE_W / 2.0)
			velocity = Vector2(hit * 360.0, -sqrt(maxf(velocity.length_squared() - hit * hit * 360.0 * 360.0, 40000.0)))
			ball.y = paddle.position.y - BALL_R - 1.0
		for i in range(bricks.size() - 1, -1, -1):
			var rect: Rect2 = bricks[i]
			if rect.intersects(Rect2(ball.x - BALL_R, ball.y - BALL_R, BALL_R * 2, BALL_R * 2)):
				bricks.remove_at(i)
				velocity.y *= -1.0
				score += 10
				break
		if ball.y > H + BALL_R:
			lives -= 1
			if lives <= 0:
				ended = true
			else:
				ball = Vector2(paddle_x, H - 105.0)
				velocity = Vector2(260.0, -300.0)
				running = false
		if bricks.is_empty():
			ended = true
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		if ended:
			new_game()
		running = true

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("090f1f"))
	draw_rect(Rect2(0, 0, W, 42), Color("111c32"))
	draw_string(ThemeDB.fallback_font, Vector2(22, 29), "BOUNCE BACK", HORIZONTAL_ALIGNMENT_LEFT, -1, 21, Color("67e8f9"))
	draw_string(ThemeDB.fallback_font, Vector2(430, 29), "SCORE  %04d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(820, 29), "LIVES  %d" % lives, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("fda4af"))
	for i in range(bricks.size()):
		var col := i % 10
		var row := int(i / 10)
		var colors := [Color("fb7185"), Color("fbbf24"), Color("a3e635"), Color("38bdf8"), Color("c084fc")]
		draw_rect(bricks[i], colors[row % colors.size()], true, 5.0)
	var paddle := Rect2(paddle_x - PADDLE_W / 2.0, H - 48.0, PADDLE_W, PADDLE_H)
	draw_rect(paddle, Color("67e8f9"), true, 8.0)
	draw_circle(ball, BALL_R, Color("ffffff"))
	draw_circle(ball, BALL_R - 4, Color("67e8f9"))
	if ended:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.68))
		draw_string(ThemeDB.fallback_font, Vector2(0, 240), "YOU BOUNCED BACK!" if bricks.is_empty() else "GAME OVER", HORIZONTAL_ALIGNMENT_CENTER, W, 38, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(0, 284), "Press SPACE to play again", HORIZONTAL_ALIGNMENT_CENTER, W, 20, Color("67e8f9"))
	elif not running:
		draw_string(ThemeDB.fallback_font, Vector2(0, 290), "MOVE  MOUSE  •  PRESS  SPACE  TO  BOUNCE", HORIZONTAL_ALIGNMENT_CENTER, W, 17, Color("cbd5e1"))
