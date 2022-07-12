function errorShade(x, y, ci, clr, ls, mkr)

x = reshape(x, 1, length(x));
y = reshape(y, 1, length(y));
[n, m] = size(ci);
if n == length(x) & m ~= length(x)
    ci = ci.';
end
[n, m] = size(ci);

if n == 10
    xShade = [x, fliplr(x)];
    yShade = [ci(1, :), fliplr(ci(10, :))];
    fill(xShade, yShade, 0.95+0.05*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    hold on
    yShade = [ci(2, :), fliplr(ci(9, :))];
    fill(xShade, yShade, 0.85+0.15*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(3, :), fliplr(ci(8, :))];
    fill(xShade, yShade, 0.75+0.25*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(4, :), fliplr(ci(7, :))];
    fill(xShade, yShade, 0.65+0.35*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(5, :), fliplr(ci(6, :))];
    fill(xShade, yShade, 0.55+0.45*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
elseif n == 8
    xShade = [x, fliplr(x)];
    yShade = [ci(1, :), fliplr(ci(8, :))];
    fill(xShade, yShade, 0.85+0.15*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    hold on
    yShade = [ci(2, :), fliplr(ci(7, :))];
    fill(xShade, yShade, 0.75+0.25*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(3, :), fliplr(ci(6, :))];
    fill(xShade, yShade, 0.65+0.35*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(4, :), fliplr(ci(5, :))];
    fill(xShade, yShade, 0.55+0.45*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
elseif n == 6
    xShade = [x, fliplr(x)];
    yShade = [ci(1, :), fliplr(ci(6, :))];
    fill(xShade, yShade, 0.75+0.25*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    hold on
    yShade = [ci(2, :), fliplr(ci(5, :))];
    fill(xShade, yShade, 0.65+0.35*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    yShade = [ci(3, :), fliplr(ci(4, :))];
    fill(xShade, yShade, 0.55+0.45*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
elseif n == 4
    xShade = [x, fliplr(x)];
    yShade = [ci(1, :), fliplr(ci(4, :))];
    fill(xShade, yShade, 0.65+0.35*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    hold on
    yShade = [ci(2, :), fliplr(ci(3, :))];
    fill(xShade, yShade, 0.55+0.45*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
elseif n == 2
    xShade = [x, fliplr(x)];
    yShade = [ci(1, :), fliplr(ci(2, :))];
    fill(xShade, yShade, 0.55+0.45*clr, 'LineStyle', 'none', 'HandleVisibility', 'off', 'FaceAlpha', 0.5)
    hold on
end

plot(x, y, 'LineStyle', ls, 'Marker', mkr, 'Color', clr)
