fabric = imread('fabric.jpg');
imshow(fabric)
title('Fabric')
 % Calculate Sample Colors in L*a*b* Color Space for Each Region

load regioncoordinates;

nColors = 6;
sample_regions = false([size(fabric,1) size(fabric,2) nColors]);

for count = 1:nColors
  sample_regions(:,:,count) = roipoly(fabric,region_coordinates(:,1,count), ...
                                      region_coordinates(:,2,count));
end

imshow(sample_regions(:,:,2))
title('Sample Region for Red')
% convertion to l*a*b
lab_fabric = rgb2lab(fabric);
% Calculate the mean 'a*' and 'b*' value for each area that you extracted with roipoly. These values serve as your color markers in 'a*b*' space.
a = lab_fabric(:,:,2);
b = lab_fabric(:,:,3);
color_markers = zeros([nColors, 2]);

for count = 1:nColors
  color_markers(count,1) = mean2(a(sample_regions(:,:,count)));
  color_markers(count,2) = mean2(b(sample_regions(:,:,count)));
end
%  Classify Each Pixel Using the Nearest Neighbor Rule
color_labels = 0:nColors-1;
% Initialize matrices to be used in the nearest neighbor classification.
a = double(a);
b = double(b);
distance = zeros([size(a), nColors]);
% Perform classification
for count = 1:nColors
  distance(:,:,count) = ( (a - color_markers(count,1)).^2 + ...
                      (b - color_markers(count,2)).^2 ).^0.5;
end

[~,label] = min(distance,[],3);
label = color_labels(label);
clear distance;
% Display Results of Nearest Neighbor Classification
rgb_label = repmat(label,[1 1 3]);
segmented_images = zeros([size(fabric), nColors],'uint8');

for count = 1:nColors
  color = fabric;
  color(rgb_label ~= color_labels(count)) = 0;
  segmented_images(:,:,:,count) = color;
end 
% Display the five segmented colors as a montage. Also display the background pixels in the image that are not classified as a color. 
montage({segmented_images(:,:,:,2),segmented_images(:,:,:,3) ...
    segmented_images(:,:,:,4),segmented_images(:,:,:,5) ...
    segmented_images(:,:,:,6),segmented_images(:,:,:,1)});
title("Montage of Red, Green, Purple, Magenta, and Yellow Objects, and Background")
% Display 'a*' and 'b*' Values of the Labeled Colors
purple = [119/255 73/255 152/255];
plot_labels = {'k', 'r', 'g', purple, 'm', 'y'};

figure
for count = 1:nColors
  plot(a(label==count-1),b(label==count-1),'.','MarkerEdgeColor', ...
       plot_labels{count}, 'MarkerFaceColor', plot_labels{count});
  hold on;
end
  
title('Scatterplot of the segmented pixels in ''a*b*'' space');
xlabel('''a*'' values');
ylabel('''b*'' values');