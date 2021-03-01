function plot_running_realfs(result)

hold on
% plot speed array. it has been bint to 1hz.
bar(result.array_treated * 100, 'black', 'EdgeColor','none', 'FaceAlpha', 0.5);

% plot each bout.
for i = 1:length(result.bout)
    boutstart = max(result.bout{i}.startidx, 1);
    boutend = min(result.bout{i}.endidx, length(result.array_treated));
%     direction = result.bout{i}.direction;
%     if direction == 1
    bar([boutstart:boutend], result.array_treated(boutstart:boutend) * 100,'r','EdgeColor','none', 'FaceAlpha', 0.5);
%     elseif direction == -1
%         bar([boutstart:boutend], result.secarray(boutstart:boutend),'r','EdgeColor','none');
%     end
end

% plot each rest period.
hold off

set(gca,'TickDir','out');

end