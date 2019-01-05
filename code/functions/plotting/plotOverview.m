function plotOverview(curr_image, curr_state, prev_state, tracked_state_keypts, ...
                      trajectory, pointcloud, num_of_latest_states, varargin)
%%PLOTOVERVIEW Pretty plotting 
%
% INPUT:
%   - curr_image(H, W): grey scale image matrix at current time t
%   - curr_state(struct): inculdes state.P(2xk) & state.X(3xk)
%   - prev_state(struct): inculdes state.P(2xk) & state.X(3xk)
%   - tracked_state_keypts(K, 1): indices of tracked keypoints in state
%   - trajectory(3, N): matrix storing entire estimated trajectory poses
%   - pointcloud(N): cells containing the landmarks detected at each pose
%   - num_of_latest_states: number of recent poses to display
%   - varargin: Arguments to print ground truth
%
% NOTE: 
% trajectory: Index 1 corresponds to the most recent entry 
% pointcloud: Last index corresponds to the most recent entry

% count minima of number of frames to be plotted and current status
num_frames_parsed = min(num_of_latest_states, size(trajectory, 2));
%% Show image with keypoints tracking
sp_1 = subplot(2, 3, [1 2]);
cla(sp_1);
imshow(curr_image);
hold on;      
% convert matrix shape from M x 2 to 2 x M
prev_keypoints = prev_state.P(tracked_state_keypts, :)';
curr_keypoints = curr_state.P';
plot(prev_keypoints(1, :), prev_keypoints(2, :), '+r', 'LineWidth', 2)
plot(curr_keypoints(1, :), curr_keypoints(2, :), '+g', 'LineWidth', 2)
title('Current frame (green: tracked keypoints in current frame)');  

%% Plot latest coordinate and landmarks
sp_2 = subplot(2, 3, [3, 6]); 
cla(sp_2);
hold on;  grid on;  
axis vis3d;
% plotting landmarks
for i = 1:num_frames_parsed
    landmarks = pointcloud{i}';
    % convert landmarks array from M x 3 to 3 x M and plot them
    if i ~= num_frames_parsed
        scatter3(landmarks(1, :), landmarks(2, :), landmarks(3, :), 5, [0.86, 0.86, 0.86]);
    end
end

% plotting most recent point cloud
landmarks = pointcloud{num_frames_parsed}';
% convert landmarks array from M x 3 to 3 x M and plot them
scatter3(landmarks(1, :), landmarks(2, :), landmarks(3, :), 5, 'k');
        
% plotting poses (done separately for a reason, believe me)
for i = 1:num_frames_parsed
    pose = reshape(trajectory(:,i), [3,4]);
    R_W_C = pose(:,1:3);
    t_W_C = pose(:,4);
    plotCoordinateFrame(R_W_C, t_W_C, 1);
end

% set axis limit for cleaner plots
t_W_C = trajectory(10:12, 1);
axis([t_W_C(1)-10, t_W_C(1)+10, ... 
      t_W_C(2)-10, t_W_C(2)+10, ...
      t_W_C(3)-10, t_W_C(3)+10]);
title(['Landmarks & Coordinates of latest ', num2str(num_of_latest_states),' frames']);  
set(gcf, 'GraphicsSmoothing', 'on');  
view(0,0);
xlabel('x (in meters)'); ylabel('y (in meters)'); zlabel('z (in meters)');


%% Plot number of tracked landmarks
sp_4 = subplot(2, 3, 4);
cla(sp_4);
count_landmarks = zeros(1, num_frames_parsed);
range = -num_of_latest_states + 1 : 0 ;
for i = 1:num_frames_parsed
    count_landmarks(i) = size(pointcloud{i}, 1);
end
% pad zeros to make range and count landmarks of same length
if num_frames_parsed < num_of_latest_states
    count_landmarks = [zeros(1, num_of_latest_states - num_frames_parsed), count_landmarks];
end
plot(range, count_landmarks);
title(['Status of latest ', num2str(num_of_latest_states),' frames']);  
xlabel('Frame number');
ylabel('Number of landmarks')
ylim([0, 1200]);
xlim([-num_of_latest_states + 1, 0])
grid on;

%% Plot full trajectory
sp_3 = subplot(2, 3, 5);
hold on; grid on; 
plot(trajectory(10, 1), trajectory(12, 1),'b.-')
title('Full Trajectory');
xlabel('x (in meters)'); ylabel('z (in meters)');
% plot ground truth if argument received
if (numel(varargin) == 1) 
    plot(varargin{1}(1), varargin{1}(2),'r.-')
    legend('Estimated Pose', 'Ground Truth');
end
% set axis limit for cleaner plots
min_x = min(trajectory(10, :));
max_x = max(trajectory(10, :));
min_z = min(trajectory(12, :));
max_z = max(trajectory(12, :));
axis([min_x-10, max_x+10, ... 
      min_z-10, max_z+10]);

end