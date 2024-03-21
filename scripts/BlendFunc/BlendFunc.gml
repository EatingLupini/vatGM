// BLEND FUNC

// linear blend
function BLEND_LINEAR_1X(frame_current, frame_count)
{
	// linear fast 1x
	return (1 / frame_count) * frame_current;
}

// linear blend 3x
function BLEND_LINEAR_3X(frame_current, frame_count)
{
	return (1 / frame_count * 3) * frame_current;
}

// blend only first few frames
function BLEND_FIRST_FRAMES(frame_current, frame_count)
{
	return min(1, max(0, 1/(frame_count/50) * frame_current));
}
