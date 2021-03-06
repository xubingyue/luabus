require("lfs");

-- log_file = nil;
local log_filename = nil;
local log_line_count = 0;
local log_max_line = 100000;

function _G.log_open(filename, max_line)
    log_filename = filename;
    log_max_line = max_line or log_max_line;
end

function _G.log_close()
    if log_file then
        log_file:close();
        log_file = nil;
    end
end

local function log_write(cate, fmt, ...)
    local now = os.time();
    local time = os.date("%H:%M:%S", now);
    fmt = string.format("%s/%s\t%s\n", time, cate, tostring(fmt));
    local ok, line = pcall(string.format, fmt, ...);
    if not ok then
        line = fmt.."... ...";
    end
    
    local args = hive.args;
    if not args or not args.daemon then
        io.stdout:write(line);
    end    

    if log_file == nil or log_line_count >= log_max_line then
        if log_file then
            log_file:close();
        end
        lfs.mkdir("log");
        time = os.date("%m%d-%H-%M-%S", now);
        local filename = string.format("log/%s-%s.log", log_filename or "out", time);
        log_file = io.open(filename, "w");
        if log_file == nil then
            return;
        end
        log_file:setvbuf("no");
		log_line_count = 0;
    end

    if not log_file:write(line) then
        log_file:close();
        log_file = nil;
        log_line_count = 0;
        return;
    end
    
    log_line_count = log_line_count + 1;
end

function _G.log_debug(fmt, ...)
    log_write("DEBUG", fmt, ...);
end

function _G.log_info(fmt, ...)
    log_write("INFO", fmt, ...);
end

function _G.log_err(fmt, ...)
    log_write("ERROR", fmt, ...);
end

