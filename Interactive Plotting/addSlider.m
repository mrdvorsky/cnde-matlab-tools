function addSlider(fig, minVal, maxVal, initialVal, callbackFunc)
    % addSliderToFigure - Adds a numeric slider, edit boxes for value, min, and max to an existing figure.
    %
    % Syntax: addSliderToFigure(fig, minVal, maxVal, initialVal, callbackFunc)
    %
    % Inputs:
    %   fig         - Handle to the existing figure.
    %   minVal      - Minimum value of the slider.
    %   maxVal      - Maximum value of the slider.
    %   initialVal  - Initial value of the slider.
    %   callbackFunc- Function handle to the user-defined callback function.
    %                 This function should take one input argument, which is
    %                 the current value of the slider.
    %
    % Example:
    %   fig = figure;
    %   addSliderToFigure(fig, 0, 10, 5, @(val) disp(['Slider value: ', num2str(val)]));

    % Ensure the figure is the current figure
    figure(fig);

    % Create the slider
    slider = uicontrol('Style', 'slider', ...
                       'Min', minVal, 'Max', maxVal, ...
                       'Value', initialVal, ...
                       'Units', 'normalized', ...
                       'Position', [0.1 0.1 0.6 0.05], ...
                       'Callback', @(src, event) sliderCallback(src, valueEditBox, callbackFunc));

    % Create the edit box for the current value
    valueEditBox = uicontrol('Style', 'edit', ...
                             'String', num2str(initialVal), ...
                             'Units', 'normalized', ...
                             'Position', [0.75 0.1 0.15 0.05], ...
                             'Callback', @(src, event) valueEditBoxCallback(src, slider, callbackFunc));

    % Create the edit box for the minimum value
    minEditBox = uicontrol('Style', 'edit', ...
                           'String', num2str(minVal), ...
                           'Units', 'normalized', ...
                           'Position', [0.1 0.05 0.2 0.05], ...
                           'Callback', @(src, event) minEditBoxCallback(src, slider, maxEditBox, valueEditBox, callbackFunc));

    % Create the edit box for the maximum value
    maxEditBox = uicontrol('Style', 'edit', ...
                           'String', num2str(maxVal), ...
                           'Units', 'normalized', ...
                           'Position', [0.4 0.05 0.2 0.05], ...
                           'Callback', @(src, event) maxEditBoxCallback(src, slider, minEditBox, valueEditBox, callbackFunc));

    % Nested callback function for the slider
    function sliderCallback(src, valueEditBox, ~)
        % Get the current value of the slider
        val = get(src, 'Value');
        
        % Update the value edit box with the current value
        set(valueEditBox, 'String', num2str(val));
        
        % Call the user-defined callback function with the current value
        callbackFunc(val);
    end

    % Nested callback function for the value edit box
    function valueEditBoxCallback(src, slider, ~)
        % Get the value entered in the edit box
        strVal = get(src, 'String');
        newVal = str2double(strVal);
        
        % Validate the input
        minVal = get(slider, 'Min');
        maxVal = get(slider, 'Max');
        if isnan(newVal) || newVal < minVal || newVal > maxVal
            % If invalid, reset the edit box to the slider's current value
            set(src, 'String', num2str(get(slider, 'Value')));
            warning('Invalid input. Value must be between %g and %g.', minVal, maxVal);
        else
            % If valid, update the slider and call the callback function
            set(slider, 'Value', newVal);
            callbackFunc(newVal);
        end
    end

    % Nested callback function for the min edit box
    function minEditBoxCallback(src, slider, maxEditBox, valueEditBox, ~)
        % Get the value entered in the min edit box
        strMin = get(src, 'String');
        newMin = str2double(strMin);
        
        % Get the current max value
        currentMax = get(slider, 'Max');
        
        % Validate the input
        if isnan(newMin) || newMin >= currentMax
            % If invalid, reset the min edit box to the current min value
            set(src, 'String', num2str(get(slider, 'Min')));
            warning('Invalid input. Min value must be less than the current max value (%g).', currentMax);
        else
            % If valid, update the slider's min value
            set(slider, 'Min', newMin);
            
            % Clamp the current value to the new range if necessary
            currentVal = get(slider, 'Value');
            if currentVal < newMin
                set(slider, 'Value', newMin);
                set(valueEditBox, 'String', num2str(newMin));
                callbackFunc(newMin);
            end
        end
    end

    % Nested callback function for the max edit box
    function maxEditBoxCallback(src, slider, minEditBox, valueEditBox, ~)
        % Get the value entered in the max edit box
        strMax = get(src, 'String');
        newMax = str2double(strMax);
        
        % Get the current min value
        currentMin = get(slider, 'Min');
        
        % Validate the input
        if isnan(newMax) || newMax <= currentMin
            % If invalid, reset the max edit box to the current max value
            set(src, 'String', num2str(get(slider, 'Max')));
            warning('Invalid input. Max value must be greater than the current min value (%g).', currentMin);
        else
            % If valid, update the slider's max value
            set(slider, 'Max', newMax);
            
            % Clamp the current value to the new range if necessary
            currentVal = get(slider, 'Value');
            if currentVal > newMax
                set(slider, 'Value', newMax);
                set(valueEditBox, 'String', num2str(newMax));
                callbackFunc(newMax);
            end
        end
    end
end